require 'rails_helper'

RSpec.describe 'Chat API', type: :request do
    
    let!(:messages) { create_list(:chat, 10)}
    let!(:message_number) {message.first.number}
    let!(:chat_number) {message.chats.first.number}
    let!(:application_token) {message.chats.first.application.token}

    # Test for GET /applications/:application_token/chats/:chat_number/messages
    describe 'GET /applications/:application_token/chats/:chat_number/messages' do
        before { get "/applications/#{application_token}/chats/#{chat_number}/messages" }

        it 'returns applications' do
            expect(json).not_to be_empty
            expect(json.size).to eq(10)
        end

        it 'returns status code 200' do
            expect(response).to have_http_status(200)
        end
    end

    # Test for POST /applications/:application_token/chats/:chat_number/messages
    describe 'POST /applications/:application_token/chats/:chat_number/messages' do
        context 'valid request' do          
            before { post "/applications/#{application_token}/chats/#{chat_number}/messages" }

            it 'returns status code 201' do
                expect(response).to have_http_status(201)
            end
        end
    end

    # Test for GET /applications/:application_token/chats/:chat_number/messages/:number
    describe 'GET /applications/:application_token/chats/:chat_number/messages/:number' do
        before { get "/applications/#{application_token}/chats/#{chat_number}/messages/#{message_number}" }

        context 'when the record exists' do
            it 'returns the message' do
                expect(json).not_to be_empty
                expect(json['token']).to eq(message_number)
            end

            it 'returns status code 200' do
                expect(response).to have_http_status(200)
            end
        end
    end

    # Test for PUT /applications/:application_token/chats/:chat_number/messages/:number
    describe 'PUT /applications/:application_token/chats/:chat_number/messages/:number' do
        let(:valid_attributes) { { content: 'New Content for the message' } }

        context 'when the record exists' do
            before { put "/applications/#{application_token}/chats/#{chat_number}/messages/#{message_number}", params: valid_attributes }

            it 'updates the record' do
                expect(json).not_to be_empty
                expect(json['name']).to eq("New Content for the message")
            end

            it 'returns status code 201' do
                expect(response).to have_http_status(201)
            end
        end
    end

    # Test for DELETE /applications/:application_token/chats/:chat_number/messages/:number
    describe 'DELETE /applications/:application_token/chats/:number' do
        before { delete "/applications/#{application_token}/chats/#{chat_number}/messages/#{message_number}" }

        it 'returns status code 201' do
            expect(response).to have_http_status(201)
        end
    end
end

