module Response
    def json_response(object, status = :ok)
        render json: object, :except=> [:id], status: status
    end

    def json_response_chats(object, status = :ok)
        render json: object, :except=> [:id, :application_id], status: status 
    end
end