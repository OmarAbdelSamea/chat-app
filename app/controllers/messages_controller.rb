class MessagesController < ApplicationController
    before_action :set_chat
    before_action :set_chat_message, only: [:show, :update, :destroy]

    # GET /applications/:application_token/chats/:chat_number/messages
    def index
        json_response_messages(@chat.messages)
    end

    # POST /applications/:application_token/chats/:chat_number/messages 
    def create
        @chat.messages.create!(message_params)
        json_response_messages(@chat.messages.last, :created)
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
        @message.update(message_params)
        json_response_messages(@message, :accepted)
    end

    # DELETE /applications/:application_token/chats/:chat_number/messages/:number
    def destroy
        @message.destroy
        json_response_messages(@message, :accepted)
    end

    private

    def message_params
        params.permit(:content)
    end

    def set_chat
        @chat = Chat.find_by_number!(params[:chat_number])
    end

    def set_chat_message
        @message = @chat.messages.find_by_number!(params[:number]) if @chat
    end
end
