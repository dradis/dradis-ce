web: ./bin/thrust ./bin/rails server
redis: redis-server --daemonize yes --port 6379 --bind 127.0.0.1
resque: QUEUE=* bundle exec rake resque:work