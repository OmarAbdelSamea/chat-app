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
        @message = @chat.messages.new(number:get_scoped_number, content:params[:content])
        CreateMessageJob.perform_later(@chat, message_params, get_scoped_number)
        json_response_messages(@message, :created)
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
            puts "Bad Request: #{exception.message}"
        end
        
    end

    def set_chat
        @chat = Chat.find_by_number!(params[:chat_number])
    end

    def set_chat_message
        @message = @chat.messages.find_by_number!(params[:number]) if @chat
    end

    def get_scoped_number
        @chat.with_lock do
            if $redis.get("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count").present?
                puts "Key found in redis"
                $redis.get("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count").to_i + 1
            else
                $redis.set("application_token:#{@chat.application.token}/chat_number:#{@chat.number}/messages_count", @chat.messages_count)
                puts "Key not found in redis"
                @chat.messages_count + 1
            end
        end
    end
end
