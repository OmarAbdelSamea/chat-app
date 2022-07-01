class ChatsController < ApplicationController
    before_action :set_application
    before_action :set_application_chat, only: [:show, :update, :destroy]

    # GET /applications/:application_token/chats 
    def index
        json_response_chats(@application.chats.order(number: :asc))
    end

    # POST /applications/:application_token/chats 
    def create
        # get the new scoped number from redis key lock result
        @count, @lock_result = get_scoped_number
        # if the lock is successfully acquired
        if @lock_result != false
            # create a model with the new scoped number for response 
            @chat = @application.chats.new(number: @count)
            # invoke sidekiq worker to create a new chat record in the db
            CreateChatJob.perform_later(@application, @count)
            json_response_chats(@chat, :created)
        else
            # if lock result is false then resource not available return error
            render :json => { :error => "Chat not created, Please try again later" }, :status => 400        
        end
    end

    # GET /applications/:application_token/chats/:number
    def show
        json_response_chats(@chat)
    end

    # DELETE /applications/:application_token/chats/:number
    def destroy
        # lock the chat number in redis before decrementing the count
        @lock_result = $red_lock.lock("application_token:#{@application.token}/chats_count", 2000)
        # if the lock is successful
        if @lock_result != false
            # get the chat count from redis and decrement it by 1
            @count = $redis.get("application_token:#{@application.token}/chats_count").to_i - 1
            # update the chat count in redis
            update_chats_count(@count)
            # unlock the chat number
            $red_lock.unlock(@lock_result)
        else
            # if the lock is not successful then return error message to try again later
            return 0, false
        end
        # if lock is successful and count value decremented then delete the chat
        @chat.destroy!
        render :json => { :result => "Chat Deleted Succesfully" }, :status => :created 
    end

    private
    
    # gets the parent application for the current chats
    def set_application
        @application = Application.find_by_token!(params[:application_token])
    end

    # gets the chat specfied in the query params
    def set_application_chat
        @chat = @application.chats.find_by_number!(params[:number]) if @application
    end

    # updates the chat count in redis
    def update_chats_count(chats_count)
        $redis.set("application_token:#{@application.token}/chats_count", chats_count)
    end

    # gets the next scoped number from redis
    def get_scoped_number
        # lock the chat number in redis before incrementing the count
        @lock_result = $red_lock.lock("application_token:#{@application.token}/chats_count", 2000)
        # if the lock is successful
        if @lock_result != false
            # check if the chat count is present or not in redis
            if $redis.get("application_token:#{@application.token}/chats_count").present?
                # get the chat count from redis and increment it by 1
                @count = $redis.get("application_token:#{@application.token}/chats_count").to_i + 1
                # update the chat count in redis
                update_chats_count(@count)
            else
                @count = @application.chats_count + 1
                # if the chat count is not present in redis then set the chat count to 1
                $redis.set("application_token:#{@application.token}/chats_count", @count)
            end
            # unlock the chat number
            $red_lock.unlock(@lock_result)
            return @count, @lock_result
        else
            return 0, false
        end
    end
end
