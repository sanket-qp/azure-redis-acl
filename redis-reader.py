from time import time
import redis
from azure.identity import ManagedIdentityCredential

scope = "acca5fbb-b7e4-4009-81f1-37e38fd66d78/.default"  # The current scope is for public preview and may change for GA release.
host = "demoredischache-shared.redis.cache.windows.net"  # Required
port = 6380  # Required
# redis-reader
friendly_username = "redis-reader"
user_name = "bfc3e9c0-e43c-4c9e-b869-6676d4e943d9" #object-id
client_id = "07c7da9d-08be-47c7-b58d-ce7cc6972d5e" #client-id

def test_read(conn, key):
    print ("Reading key: %s", key)
    resp = conn.get(key)
    print ("Got the value: %s", resp)

def test_write(conn, key, val):
    print ("Writing key: %s", key)
    conn.set(key, val)

def test_sorted_set(conn):
    set_name = "players"
    conn.zadd(set_name, {"Alice": 25})
    conn.zadd(set_name, {"Bob": 22})
    print ("set contents: %s" % conn.zrange(set_name, 0, -1, withscores=True))

def test_stream(conn):
    try:
        stream_key = "skey"
        for i in range(0,10):
            conn.xadd( stream_key, { 'ts': time(), 'v': i } )
        print( f"stream length: {conn.xlen( stream_key )}")
    except Exception as e:
        print (e)
        print ("Stream operations are not supported for the user: %s" % friendly_username)

def test_pubsub(conn):
    try:
        channel_name = "hello_channel"
        conn.publish(channel_name, "HELLO")

        x = conn.pubsub()
        x.subscribe(channel_name)
        for msg in x.listen():
            print("MESSAGE: %s" % msg)

    except Exception as e:
        print (e)
        print ("PubSub operations are not supported for the user: %s" % friendly_username)

def hello_world():
    cred = ManagedIdentityCredential(client_id=client_id)
    token = cred.get_token(scope)
    # print ("token:",  token)
    r = redis.Redis(host=host,
                    port=port,
                    ssl=True,    # ssl connection is required.
                    username=user_name,
                    password=token.token,
                    decode_responses=True)

    print ("--------------------------------")
    test_write(r, "AZ:key1", "value1")
    print ("--------------------------------")
    test_read(r, "AZ:key1")
    print ("--------------------------------")
    test_sorted_set(r)
    print ("--------------------------------")
    test_stream(r)
    print ("--------------------------------")
    test_pubsub(r)
    print ("--------------------------------")


if __name__ == '__main__':
    hello_world()
