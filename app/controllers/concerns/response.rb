module Response
    def json_response(object, status = :ok)
        render json: object, :except=> [:id], status: status
    end

    def json_response_chats(object, status = :ok)
        render json: object, :except=> [:id, :application_id], \
        :include => [:application => {:except=> [:id, :chats_count, :updated_at]}], \
        status: status 
    end

    def json_response_messages(object, status = :ok)
        render json: object, :except=> [:id, :chat_id], \
        :include => [:chat => {:except=> [:id, :messages_count, :application_id, :updated_at]}], \
        status: status 
    end
end