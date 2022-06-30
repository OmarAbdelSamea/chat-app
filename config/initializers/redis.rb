require 'redis'

redis_config = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}/12" }

begin
    $redis = Redis.new(redis_config)
rescue Exception => e
    puts e
end