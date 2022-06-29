require 'rails_helper'

RSpec.describe 'Chat API', type: :request do
    
    let!(:chats) { create_list(:chat, 10)}
    let!(:chat_number) {chats.first.number}
    let!(:application_token) {chats.first.application.token}

    # Test for GET /applications/:application_token/chats
    describe 'GET /applications/:application_token/chats' do
        before { get "/applications/#{application_token}/chats" }

        it 'returns applications' do
            expect(json).not_to be_empty
            expect(json.size).to eq(10)
        end

        it 'returns status code 200' do
            expect(response).to have_http_status(200)
        end
    end

    # Test for POST /applications/:application_token/chats
    describe 'POST /applications/:application_token/chats' do
        context 'valid request' do          
            before { post "/applications/#{application_token}/chats" }

            it 'returns status code 201' do
                expect(response).to have_http_status(201)
            end
        end
    end

    # Test for GET /applications/:application_token/chats/:number
    describe 'GET /applications/:application_token/chats/:token' do
        before { get "/applications/#{application_token}/chats/#{chat_number}" }

        context 'when the record exists' do
            it 'returns the chat' do
                expect(json).not_to be_empty
                expect(json['number']).to eq(chat_number)
            end

            it 'returns status code 200' do
                expect(response).to have_http_status(200)
            end
        end
    end

    # Test for DELETE /applications/:application_token/chats/:number
    describe 'DELETE /applications/:application_token/chats/:number' do
        before { delete "/applications/#{application_token}/chats/#{chat_number}" }

        it 'returns status code 204' do
        expect(response).to have_http_status(204)
        end
    end
end

