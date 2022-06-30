class ApplicationsController < ApplicationController
    before_action :set_application, only: [:show, :update, :destroy]
    before_action :application_params, only: [:create, :update]

    # GET /applications 
    def index
        @applications  = Application.all
        json_response(@applications)
    end

    # POST /applications
    def create
        @application = Application.create!(application_params)
        json_response(@application, :created)
    end

    # GET /applications/:token
    def show
        json_response(@application)
    end

    # PUT /applications/:token
    def update
        @application.update(application_params)
        head :no_content
    end

    # DELETE /applications/:token
    def destroy
        @application.destroy
        render :json => { :result => "Application Deleted Succesfully" }, :status => :created 
    end

    private
    
    def application_params
        begin
            params.require(:name)
            params.permit(:name)
        rescue => exception
            render :json => { :error => exception.message }, :status => 400 
        end
    end
    
    def set_application
        @application = Application.find_by_token!(params[:token])
    end

end
