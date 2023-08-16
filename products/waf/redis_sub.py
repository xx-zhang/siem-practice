import redis

r = redis.Redis(host='172.17.0.1', port=32771)
pubsub = r.pubsub()
pubsub.subscribe('topnsm_nginx_logs')

for message in pubsub.listen():
    print(message)
    if message['type'] == 'message':
        print(f"Received: {message['data'].decode('utf-8')}")
