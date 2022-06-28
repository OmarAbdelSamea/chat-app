module Response
    def json_response(object, status = :ok)
        render json: object, :except=> [:id], status: status
    end

    def json_response_chats(object, status = :ok)
        render json: object, :except=> [:id, :application_id], \
        :include => [:application => {:only=> [:token, :name, :created_at]}], \
        status: status 
    end

    def json_response_messages(object, status = :ok)
        render json: object, :except=> [:id, :chat_id], \
        :include => [:chat => {:only=> [:number, :created_at]}], \
        status: status 
    end

    def json_response_messages_search(object, status = :ok)
        render json: object, :except=> [:id, :chat_id, :_index, :_type, :_id], \
        :include => [:chat => {:only=> [:number, :created_at]}], \
        status: status 
    end
end