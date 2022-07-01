
<div align="center">
<h3 align="center">Rails Chat System</h3>


</div>
<!-- TABLE OF CONTENTS -->
<summary>Table of Contents</summary>
<ol>
  <li>
    <a href="#about-the-project">About the Project</a>
    <ul>
      <li><a href="#demo">Demo</a></li>
    </ul>
    <ul>
      <li><a href="#architecture">Architecture</a></li>
    </ul>
    <ul>
      <li><a href="#models">Models</a></li>
    </ul>
    <ul>
      <li><a href="#technologies">Technologies</a></li>
    </ul>
    <ul>
      <li><a href="#endpoints">Endpoints</a></li>
    </ul>
  </li>
  <li>
    <a href="#getting-started">Getting Started</a>
  </li>
  <li><a href="#development-process">Development Process</a>
  </li>
</ol>

<!-- ABOUT THE PROJECT -->
# About The Project
Chat system that allows creating new applications, chats and messages the applications supports running on multiple servers in parallel by processing requests concurrently using queues and locks.

## Demo
https://user-images.githubusercontent.com/57943026/176784778-b103703b-268b-4935-91fe-ce156db4885f.mp4

## Architecture
![image](https://user-images.githubusercontent.com/57943026/176658099-9c6403ac-f963-4a3e-ad40-bca3551e2bca.png)

## Models
![image](https://user-images.githubusercontent.com/57943026/176662512-f0ad67ac-3466-4c9e-a58b-fe011b31414e.png)

## Technologies
- Main Framework: Ruby on Rails
- Containerization: Docker 
- Orchestration: Docker Compose
- Queuing: Sidekiq, Redis
- Cron Jobs: Sidekiq-cron

## Endpoints
  - ![image](https://user-images.githubusercontent.com/57943026/176763371-743c2b91-1478-4804-b359-fd31782e1406.png)

## Request and Response
### Application

#### Request 
```json
  {
    "name": "This is name of the application"
  }
```
#### Response
```json
  {
    "token": "7tftdi4PJLqXhCmQtzcypqci",
    "name": "This is name of the application",
    "chats_count": 0,
    "created_at": "2022-06-29T12:22:03.000Z",
    "updated_at": "2022-06-29T12:22:03.000Z"
  }
```

### Chat
#### Request 
`None`
#### Response
```json
  {
    "number": 1,
    "messages_count": 0,
    "application": {
      "token": "7tftdi4PJLqXhCmQtzcypqci",
      "name": "This is name of the application",
      "created_at": "2022-06-29T12:22:03.000Z"
    }
  }
```

### Message Response
#### Request 
```json
  {
    "content": "This is content of the message"
  }
```
#### Response
```json
  {
    "number": 1,
    "content": "This is content of the message",
    "chat": {
      "number": 1,
      "created_at": "2022-06-29T12:22:03.000Z"
    }
  }
```

<!-- GETTING STARTED -->
# Getting Started
```bash
1. docker-compose run web bundle install
2. docker-compose run web rails db:setup
3. docker-compose up
```

# Development Process
### 1. Extracting Models from requirements:
  - Application
  - Chat
  - Message
### 2. Identifying relationships between models
  - Application has many chats -> one to many relationship
  - Chat has many messages -> one to many relationship
### 3. Creating Migrations with the appropriate indices and constraints.
  - number index in `Chat` and `Message` is scoped to the super class so it can't be unique.
  - for application token `ActiveRecord::SecureToken::ClassMethods` is used in Application model to generate a unique 24 byte unique token.
```ruby
class CreateApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :applications do |t|
      t.string :token, unique: true, null: false
      t.string :name, null: false
      t.integer :chats_count, default: 0

      t.timestamps
    end
  end
end
```
```ruby
class CreateChats < ActiveRecord::Migration[5.2]
  def change
    create_table :chats do |t|
      t.integer :number, null: false
      t.integer :messages_count, default: 0
      t.references :application, foreign_key: true

      t.timestamps
    end
  end
end
```
```ruby
class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.integer :number, null: false
      t.text :content, null: false
      t.references :chat, foreign_key: true

      t.timestamps
    end
  end
end
```

### 4. Writing unit tests (specs) for Test Driven Development approach
  - [Applications Spec](https://github.com/OmarAbdelSamea/chat-app/blob/master/spec/requests/applications_spec.rb)
  - [Chats Spec](https://github.com/OmarAbdelSamea/chat-app/blob/master/spec/requests/chats_specs.rb)
  - [Messages Spec](https://github.com/OmarAbdelSamea/chat-app/blob/master/spec/requests/messages_specs.rb)

### 5. Writing RESTful endpoints in controllers which pass all tests
  - [Applications Controller](https://github.com/OmarAbdelSamea/chat-app/blob/master/app/controllers/applications_controller.rb)
  - [Chats Controller](https://github.com/OmarAbdelSamea/chat-app/blob/master/app/controllers/chats_controller.rb)
  - [Messages Controller](https://github.com/OmarAbdelSamea/chat-app/blob/master/app/controllers/messages_controller.rb)

### 6. Check tests if it fails repeat cycle until all tests pass
  
```ruby
.................

Finished in 2.01 seconds (files took 2.86 seconds to load)
17 examples, 0 failures

```

### 7. After Getting familiar with Ruby on Rails, started containerization process of Rails app and MySQL Database
  - [Dockerfile](https://github.com/OmarAbdelSamea/chat-app/blob/master/Dockerfile)
  - [Docker-compose](https://github.com/OmarAbdelSamea/chat-app/blob/master/docker-compose.yml)

### 8. Adding search endpoint for messages using `elastic search`
  - Adding `ElasticSearch` in Message model
  - Creating search endpoint in Messages controller
  - Response: search string: `Github`
  ```json
  [
      {
          "_score": 3.5032253,
          "_source": {
              "number": 37,
              "content": "Bye Github",
              "created_at": "2022-06-30T18:16:04.000Z",
              "updated_at": "2022-06-30T18:16:04.000Z"
          }
      },
      {
          "_score": 3.1505516,
          "_source": {
              "number": 36,
              "content": "Hello from Github",
              "created_at": "2022-06-30T18:15:43.000Z",
              "updated_at": "2022-06-30T18:15:43.000Z"
          }
      }
  ]
  ```

### 9.  Containerization of elasticsearch
```yaml
elasticsearch:
  image: docker.elastic.co/elasticsearch/elasticsearch:7.8.1
  environment:
    - node.name=chat-app-node-1
    - cluster.name=es-docker-cluster
    - discovery.type=single-node
    - bootstrap.memory_lock=true
  ulimits:
    memlock:
      soft: -1
      hard: -1
  volumes:
    - elasticsearch:/usr/share/elasticsearch/data
  ports:
    - 9200:9200
```
### 10. Handling parallel processing and system distribution by using queues
  1. Analyzing options
    - Sidekiq
    - RabbitMQ
    - Kafka
  2. Selecting one of the options -> Sidekiq 
  3. Selecting an appropriate storage for workers -> Redis (Sidekiq default)

  ```ruby
  class CreateChatJob < ApplicationJob
    queue_as :default

    def perform(*args)
      application = args[0]
      chat_number = args[1]
      # sleep 2 # for testing purposes
      application.chats.create!(number: chat_number)
    end
  end
  ```
  ```ruby
  class CreateMessageJob < ApplicationJob
    queue_as :default

    def perform(*args)
      chat = args[0]
      message_params = args[1]
      message_number = args[2]
      # sleep 2 for testing purposes
      chat.messages.create!(number: message_number, content: message_params)
    end
  end
  ```
  ```ruby
  class UpdateMessageJob < ApplicationJob
    queue_as :default

    def perform(*args)
      message = args[0]
      message_params = args[1]
      # pessimistic locking in MySQL database until the record is updated
      message.with_lock do
        message.update!(message_params)
      end
    end
  end
  ```
### 11.  Containerization of Sidekiq and Redis
```yaml
redis:
  image: redis:7.0.2-bullseye
  command: redis-server
  volumes:
    - redis:/data
  ports:
    - 6379
  logging:
          driver: none
sidekiq:
  build: ./
  command: bundle exec sidekiq
  volumes:
    - ./:/workspace
  environment:
    DB_USERNAME: root
    DB_PASSWORD: root
    DB_NAME: chat_app_development
    DB_PORT: 3306
    DB_HOST: db
    RAILS_ENV: development
    REDIS_HOST: redis
    REDIS_PORT: 6379
    ELASTICSEARCH_URL: "http://elasticsearch:9200"
  depends_on:
    - "db"
    - "web"
    - "redis"
    - "elasticsearch"
```
### 12. Saving queries by using Redis
   - Saving `chats_count` and `messages_count` in Redis instead of MySQL with each new record for higher performance 

### 13. Adding pessimistic locks for Redis (redlock gem) to avoid race conditions while updating `chats_count` and `messages_count`
  - Example from chats controller, same approach implemented in messages controller
  ```ruby
  # lock the chat number in redis before incrementing the count
  @lock_result = $red_lock.lock("application_token:#{@application.token}/chats_count", 2000)
  # if the lock is successful
  if @lock_result != false
      # check if the chat count is present or not in redis
      if $redis.get("application_token:#{@application.token}/chats_count").present?
          # get the chat count from redis and increment it by 1
          @count = $redis.get("application_token:#{@application.token}/chats_count").to_i + 1
          # update the chat count in redis
          update_chats_count(@count)
      else
          @count = @application.chats_count + 1
          # if the chat count is not present in redis then set the chat count to 1
          $redis.set("application_token:#{@application.token}/chats_count", @count)
      end
      # unlock the chat number
      $red_lock.unlock(@lock_result)
      return @count, @lock_result
  else
      return 0, false
  end
  ```

### 14. Adding pessimistic lock for MySQL to avoid race conditions while updating applications/chats/messages
  ```ruby 
  def perform(*args)
    message = args[0]
    message_params = args[1]
    # pessimistic locking in MySQL database until the record is updated
    message.with_lock do
      message.update!(message_params)
    end
  end
  ```
### 15. Adding Cron Job to update `chats_count` and `messages_count` in MySQL from Redis
```ruby
save_counts_persistent:
  cron: "* * * * *" # this runs the job every minute for demos
  # cron: "0 * * * *" this runs the job every hour
  class: "SaveCountsPersistentJob"
  queue: default
```

```ruby
class SaveCountsPersistentJob < ApplicationJob
  queue_as :default

  def perform(*args)
      # get all applications in MySQL database
    Application.find_each do |application|
      # check if present in redis or not
      if $redis.get("application_token:#{application.token}/chats_count").present?
        # if present then get the chat count from redis and update it in MySQL database
        application.chats_count = $redis.get("application_token:#{application.token}/chats_count").to_i
        application.save!
      end
    end

    # get all chats in MySQL database
    Chat.find_each do |chat|
      # check if present in redis or not
      if $redis.get("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count").present?
        # if present then get the message count from redis and update it in MySQL database
        chat.messages_count = $redis.get("application_token:#{chat.application.token}/chat_number:#{chat.number}/messages_count").to_i
        chat.save!
      end
    end
  end
end
```
### 16. Writing RESTful API compliant to openapi standard
[openapi.yaml](https://github.com/OmarAbdelSamea/chat-app/blob/master/openapi.yaml)
