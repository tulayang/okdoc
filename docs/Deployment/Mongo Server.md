部署 Mongo 集群
--------------- 

1. 启动实例
  
       $ mongod --dbpath data/n1 --port 31000 --replSet my
       $ mongod --dbpath data/n1 --port 31001 --replSet my
       $ mongod --dbpath data/n1 --port 31002 --replSet my

2. 连接主节点并配置

       $ mongo 127.0.0.1:31000
       > rs.initiate()
       > rs.add('king-PC:31001')
       > rs.add('king-PC:31002')

       var config = {
            _id:'spock', 
            members:[
                {_id:0, host:'king-PC:31000'},
                {_id:1, host:'king-PC:31001'},
                {_id:2, host:'king-PC:31002'}
            ]
        }
   
       > rs.initiate(config) 
       > rs.reconfig(config)  重新设置配置 

       > db.isMaster()

3. 备份节点可读配置

       $ mongo 127.0.0.1:31001
       > db.setSlaveOk()
       > db.users.find()
