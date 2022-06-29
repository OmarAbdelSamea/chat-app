class ChatsController < ApplicationController
    before_action :set_application
    before_action :set_application_chat, only: [:show, :update, :destroy]

    # GET /applications/:application_token/chats 
    def index
        json_response_chats(@application.chats)
    end

    # POST /applications/:application_token/chats 
    def create
        @chat = @application.chats.new(number: get_scoped_number)
        CreateChatJob.perform_later(@application)
        json_response_chats(@chat, :created)
    end

    # GET /applications/:application_token/chats/:number
    def show
        json_response_chats(@chat)
    end

    # DELETE /applications/:application_token/chats/:number
    def destroy
        @chat.destroy!
        render :json => { :result => "Chat Deleted Succesfully" }, :status => :created 
    end

    private
    
    def set_application
        @application = Application.find_by_token!(params[:application_token])
    end

    def get_scoped_number
        @application.with_lock do
            @application.chats_count + 1
        end
    end

    def set_application_chat
        @chat = @application.chats.find_by_number!(params[:number]) if @application
    end
end
