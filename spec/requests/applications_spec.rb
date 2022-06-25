require 'rails_helper'

RSpec.describe 'Application API', type: :request do
    
    let!(:applications) { create_list(:application, 10)}
    let!(:application_token) {applications.first.token}

    # Test for GET /applications
    describe 'GET /applications' do
        before { get '/applications' }

        it 'returns applications' do
            expect(json).not_to be_empty
            expect(json.size).to eq(10)
        end

        it 'returns status code 200' do
            expect(response).to have_http_status(200)
        end
    end

    # Test for POST /applications
    describe 'POST /applications' do
        let(:valid_attributes) {{ name: 'TestAPP' }}

        context 'valid request' do          
            before { post '/applications', params: valid_attributes}

            it 'create a new application' do
                expect(json['name']).to eq('TestAPP')
            end

            it 'returns status code 201' do
                expect(response).to have_http_status(201)
            end
        end

        context 'invalid request' do
            before { post '/applications', params: { invalid_title: 'Invalid Name'}}

            it 'returns status code 422' do
                expect(response).to have_http_status(422)
            end
        
            it 'returns a validation failure message' do
                expect(response.body)
                .to match(/Validation failed: Name can't be blank/)
            end
        end
    end

    # Test for GET /applications/:id
    describe 'GET /applications/:token' do
        before { get "/applications/#{application_token}" }

        context 'when the record exists' do
            it 'returns the todo' do
                expect(json).not_to be_empty
                expect(json['token']).to eq(application_token)
            end

            it 'returns status code 200' do
                expect(response).to have_http_status(200)
            end
        end
    end

    # Test for PUT /applications/:token
    describe 'PUT /applications/:token' do
        let(:valid_attributes) { { name: 'UpdateName' } }

        context 'when the record exists' do
            before { put "/applications/#{application_token}", params: valid_attributes }

            it 'updates the record' do
                expect(response.body).to be_empty
            end

            it 'returns status code 204' do
                expect(response).to have_http_status(204)
            end
        end
    end

    # Test suite for DELETE /applications/:token
    describe 'DELETE /applications/:token' do
        before { delete "/applications/#{application_token}" }

        it 'returns status code 204' do
        expect(response).to have_http_status(204)
        end
    end
end

