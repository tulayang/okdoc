## 服务器

```
import net, threadpool

var 
    server = newSocket()
    client: Socket
    clientAddress: string

bindAddr(server, Port(8001), "127.0.0.1")
listen(server)
new(client)

setSockOpt(server, OptDontRoute, true)
setSockOpt(server, OptKeepAlive, true)
echo "--- broadcast: ",  getSockOpt(server, OptBroadcast)
echo "--- accept: ",     getSockOpt(server, OptAcceptConn)
echo "--- debug: ",      getSockOpt(server, OptDebug)
echo "--- dont route: ", getSockOpt(server, OptDontRoute)
echo "--- keep alive: ", getSockOpt(server, OptKeepAlive)
echo "--- oob inline: ", getSockOpt(server, OptOOBInline)
echo "--- reuse addr: ", getSockOpt(server, OptReuseAddr)

echo "--- ssl?: ",           isSsl(server)
echo "--- handle: ",         repr(getFd(server))
echo "--- IPv4 any : ",      IPv4_any()
echo "--- IPv4 loopback: ",  IPv4_loopback()
echo "--- IPv4 broadcast: ", IPv4_broadcast()
echo "--- IPv6 any : ",      IPv6_any()
echo "--- IPv6 loopback: ",  IPv6_loopback()

proc longtime() =
    for i in 0..200_000_000: discard

proc work(client: Socket) =
    longtime()
    var clientLine: TaintedString = ""
    echo "--- read line begin"
    while true:
        readLine(client, clientLine)
        if len(clientLine) == 0: break
        echo "--- read line: ", clientLine
    echo ">>> read line finish"

while true:
    echo "--- accpet begin"
    acceptAddr(server, client, clientAddress)
    spawn work(client)
    echo ">>> accept finish"
```

## 客户端

```
import net

var 
    socket: Socket

for i in 0..2:
    echo "--- connect begin"
    socket = newSocket()
    connect(socket, "127.0.0.1", Port(8001))
    send(socket, "Hello server!\r\nHow are you doing?\r\n......\r\n")
    send(socket, "Hello server!\r\nHow are you doing?\r\n......\r\n")
    close(socket)    
    echo ">>> connect finish"

```