import json 
import redis

r = redis.Redis(host='172.17.0.1', port=32771)
pubsub = r.pubsub()
pubsub.subscribe('topnsm_modsec_logs')

for message in pubsub.listen():
    print(message)
    if message['type'] == 'message':
        print(f"Received: {message['data'].decode('utf-8')}")
        print(json.dumps(json.loads(message['data'].decode('utf-8')), ensure_ascii=True, indent=2))
