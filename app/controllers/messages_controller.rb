class MessagesController < ApplicationController
    before_action :set_chat
    before_action :set_chat_message, only: [:show, :update, :destroy]
    before_action :message_params, only: [:create, :update, :search]

    # GET /applications/:application_token/chats/:chat_number/messages
    def index
        json_response_messages(@chat.messages)
    end

    # POST /applications/:application_token/chats/:chat_number/messages 
    def create
        # get the new scoped number from redis and key lock result
        @count, @lock_result = get_scoped_number
        # if the lock is successfully acquired
        if @lock_result != false
            # create a model with the new scoped number for response
            @message = @chat.messages.new(number:@count, content:params[:content])
            # invoke sidekiq job to create a new message record in the db
            CreateMessageJob.perform_later(@chat, params[:content], @count)
            json_response_messages(@message, :created)
        else
            # if lock result is false then resource not available return error
            render :json => { :error => "Chat not created, Please try again later" }, :status => 400        
        end
    end

    # POST /applications/:application_token/chats/:chat_number/messages/search 
    def search
        @search_result = Message.search params[:content]
        json_response_messages_search(@search_result, :created)
    end

    # GET /applications/:application_token/chats/:chat_number/messages/:number 
    def show
        json_response_messages(@message)
    end

    # PUT /applications/:application_token/chats/:chat_number/messages/:number
    def update
        @message.content = params[:content]
        UpdateMessageJob.perform_later(@message, message_params)
        json_response_messages(@message, :accepted)
    end

    # DELETE /applications/:application_token/chats/:chat_number/messages/:number
    def destroy
        # lock the message number in redis before decrementing the count
        @lock_result = $red_lock.lock("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count", 3000)
        # if the lock is successfully acquired
        if @lock_result != false
            # get the message count from redis and decrement it by 1
            @count = $redis.get("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count").to_i - 1
            # update the message count in redis
            update_messages_count(@count)
            # unlock the message number
            $red_lock.unlock(@lock_result)
        end
        # if lock is successful and count value decremented then delete the message
        @message.destroy!
        render :json => { :result => "Message Deleted Succesfully" }, :status => :created 
    end

    private

    # gets the application params from the request
    def message_params
        begin
            params.require(:content)
            params.permit(:content)
        rescue => exception
            render :json => { :error => exception.message }, :status => 400 
        end
        
    end

    # get the parent chat for the current messages
    def set_chat
        @chat = Chat.find_by_number!(params[:chat_number])
    end

    # get the message specfied in the query params
    def set_chat_message
        @message = @chat.messages.find_by_number!(params[:number]) if @chat
    end

    # update the message count in redis
    def update_messages_count(messages_count)
        $redis.set("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count", messages_count)
    end

    # gets the next scoped number from redis
    def get_scoped_number
        # lock the message number in redis before incrementing the count
        @lock_result = $red_lock.lock("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count", 3000)
        # if the lock is successfully acquired
        if @lock_result != false
            # check if the message count is present or not in redis
            if $redis.get("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count").present?
                # get the message count from redis and increment it by 1
                @count = $redis.get("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count").to_i + 1
                # update the message count in redis
                update_messages_count(@count)
            else
                @count = @chat.messages_count + 1
                # if the message count in not present in redis then set the message count to 1
                $redis.set("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count", @count)
            end
            # unlock the message number
            $red_lock.unlock(@lock_result)
            return @count, @lock_result
        else
            return 0, false
        end
    end

end
