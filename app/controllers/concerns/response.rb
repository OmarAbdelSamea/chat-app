module Response
    def json_response(object, status = :ok)
        render json: object, :except=> [:id], status: status
    end
end