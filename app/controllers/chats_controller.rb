class ChatsController < ApplicationController
    before_action :set_application
    before_action :set_application_chat, only: [:show, :update, :destroy]

    # GET /applications/:application_token/chats 
    def index
        json_response_chats(@application.chats)
    end

    # POST /applications/:application_token/chats 
    def create
        @count, @lock_result = get_scoped_number
        puts "Count: #{@count}, Lock Result: #{@lock_result}"
        if @lock_result != false
            @chat = @application.chats.new(number: @count)
            CreateChatJob.perform_later(@application, @count)
            json_response_chats(@chat, :created)
        else
            render :json => { :error => "Chat not created, Please try again later" }, :status => 400        
        end
    end

    # GET /applications/:application_token/chats/:number
    def show
        json_response_chats(@chat)
    end

    # DELETE /applications/:application_token/chats/:number
    def destroy
        @lock_result = $red_lock.lock("application_token:#{@application.token}/chats_count", 2000)
        if @lock_result != false
            @count = $redis.get("application_token:#{@application.token}/chats_count").to_i - 1
            update_chats_count(@count)
            $red_lock.unlock(@lock_result)
        else
            puts "resource not availble"
            return 0, false
        end
        @chat.destroy!
        render :json => { :result => "Chat Deleted Succesfully" }, :status => :created 
    end

    private
    
    def set_application
        @application = Application.find_by_token!(params[:application_token])
    end

    def update_chats_count(chats_count)
        $redis.set("application_token:#{@application.token}/chats_count", chats_count)
    end

    def get_scoped_number
        @lock_result = $red_lock.lock("application_token:#{@application.token}/chats_count", 2000)
        if @lock_result != false
            if $redis.get("application_token:#{@application.token}/chats_count").present?
                puts "Key found in redis"
                @count = $redis.get("application_token:#{@application.token}/chats_count").to_i + 1
                update_chats_count(@count)
            else
                @count = @application.chats_count + 1
                puts "Key not found in redis"
                $redis.set("application_token:#{@application.token}/chats_count", @count)
            end

            puts "Chat count incremented in Redis #{$redis.get("application_token:#{@application.token}/chats_count").to_i}"
            $red_lock.unlock(@lock_result)

            return @count, @lock_result
        else
            puts "resource not availble"
            return 0, false
        end
    end

    def set_application_chat
        @chat = @application.chats.find_by_number!(params[:number]) if @application
    end
end
