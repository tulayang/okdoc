
1. Start Server (启动3个服务器实例)

       $ mongod --replSet myset -f data/node0/mongo.conf
       $ mongod --replSet myset -f data/node1/mongo.conf
       $ mongod --replSet myset -f data/node2/mongo.conf

       mongo.conf:

       port            = 31000
       fork            = true
       dbpath          = /home/king/node_worker/test/data/node0
       logpath         = /home/king/node_worker/test/data/node0/mongo.log
       logappend       = true
       bind_ip         = 127.0.0.1
       nohttpinterface = true
       noscripting     = true

2. Config Sets (连接到主服务器，配置副本集)

       $ mongo 127.0.0.1:31000
       > var conf = {
           _id: 'myset',
           members: [
             {_id:0, host:'king-PC:31000', priority:3},
             {_id:0, host:'king-PC:31001', priority:2},
           {_id:0, host:'king-PC:31002', priority:1}
           ]
         };
       > rs.initiate(conf);

3. Config Slave (连接到备份服务器，配置可读)

       $ mongo 127.0.0.1:31001
       > db.setSlaveOk()


