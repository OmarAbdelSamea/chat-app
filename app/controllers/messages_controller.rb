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
        @count, @lock_result = get_scoped_number
        puts "Count: #{@count}, Lock Result: #{@lock_result}"
        if @lock_result != false
            @message = @chat.messages.new(number:@count, content:params[:content])
            CreateMessageJob.perform_later(@chat, params[:content], @count)
            json_response_messages(@message, :created)
        else
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
        @message.destroy
        render :json => { :result => "Message Deleted Succesfully" }, :status => :created 
    end

    private

    def message_params
        begin
            params.require(:content)
            params.permit(:content)
        rescue => exception
            render :json => { :error => exception.message }, :status => 400 
        end
        
    end

    def set_chat
        @chat = Chat.find_by_number!(params[:chat_number])
    end

    def set_chat_message
        @message = @chat.messages.find_by_number!(params[:number]) if @chat
    end

    def increment_messages_count(messages_count)
        $redis.set("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count", messages_count)
    end

    def get_scoped_number
        @lock_result = $red_lock.lock("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count", 3000)
        if @lock_result != false
            if $redis.get("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count").present?
                puts "Key found in redis"
                @count = $redis.get("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count").to_i + 1
                increment_messages_count(@count)
            else
                @count = @chat.messages_count + 1
                puts "Key not found in redis"
                $redis.set("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count", @count)
            end
            sleep 2
            puts "Chat count incremented in Redis #{$redis.get("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count").to_i}"
            $red_lock.unlock(@lock_result)

            return @count, @lock_result
        else
            puts "resource not availble"
            return 0, false
        end
    end

end
