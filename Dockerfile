FROM ruby:2.7.0
ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y nodejs \
        --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle install

ENV RUBYOPT=-W:no-deprecated
ENV APP_ROOT=/workspace
RUN mkdir -p $APP_ROOT
WORKDIR $APP_ROOT
COPY . $APP_ROOT

EXPOSE  3000
CMD rm -f tmp/pids/server.pid && rails s -b '0.0.0.0'