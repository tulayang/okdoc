http://www.vaikan.com/sort-dance/
  
# START

    $ mongod -f /data/db/mongo.conf 使用配置文件启动Mongo服务器
      .mongorc.js

    $ mongo --nodb  
    > var conn = new Mong('host:port');
    > var db = conn.getDB('test');

    $ mongo 127.0.0.1:27017 -f /data/db/mongo.conf
      * --nodb         不连接到实例
      * --config       配置
      * --fork         fork子进程
      * --noscripting  关闭脚本注入

# 副本集

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


# BASE

  * help 帮助文档

  * use DB 选择数据库

  * show dbs 显示当前实例所有的数据库

  * show collections 显示当前数据库所有的集合 

  * EDITOR="/path" 设置编辑器

  * edit VAR 使用编辑器编辑VAR

  * 可以比较Date类型($lt $lte $gt $gte)


# CRUD

  * insert(query, options) 插入(批量)
    
        db.users.insert({it:1}, {})
        db.users.insert([{it:1},{it:2},...], {})

        // continueOnError 出现错误后边的项继续插入

  * update(query, docs, upsert, multi) 更新(批量)

        db.users.update({_id:1}, {$set:{it:2}}, false, true)
        db.users.update({_id:1}, {$unset:{it:1}}, false, true)
        db.users.update({_id:1}, {$inc:{it:2}}, false, true)
        db.users.update({_id:1}, {$push:{tags:'fruit'}}, false, true)
        db.users.update({_id:1}, {$push:{tags:{$each:['fruit','big'],$slice:[0,2]}}}, false, true)
    
    操作符：
    
    - $inc: {...}         计数
    - $set: {...}         设定
    - $unset: {...}       取消
    - $push: {...}        压入数组
    - $pop: {...}         压出数组(前1、后-1)
    - $poll: {...}        压出数组(值)
    - $addToSet: {...}    压入(如果不存在)
      - $each: []         多个
      - $slice: V         提取，只能是负数或者0

    更新并显示结果：
    
        db.runCommand({
            findAndModify: 'users',
            query: {...},
            update: {...},
            remove: {...},
            new: true | false,  // 返回更新后的文档
            sort: {...},
            fields: {...},
            upsert: true | false
        })

  * find(query, fields, limit, skip, batchSize, options)

        db.users.find({it:{$gt:1, $lt:12}, tt:{$in:[1,2]}}, {_id:0,it:1}).limit(1).skip(1000).sort({it:1})

              fields    : 投射配置
              limit     : 返回文档个数
              skip      : 跳过文档个数
              batchSize : 批大小，批量查询设定的查询数

    findOne(query, fields, options)
    
      - $and: [{}, {}, ...]
      - $or: [{}, {}, ...]
      - $nor: [{}, {}, ...]
      - { age: /^li$/i}
          - $lt $lte $gt $gte: V
          - $in: []
          - $nin: []
          - $exists: true | false
          - $not: V
          - $mod: [a, b] 取模
          - $all: []
          - $size: V
          - $elemMatch: {}


# 聚合管道

  * aggregate(o)
    
        db.users.aggregate({
            $match:{}    // 查询选择器（不能使用地理空间操作符）  
            $project:{}  // 投射
            $group:{}    // 分组，映射聚合 _id
            $sort:{}     // 排序
            $limit:V     // 返回的文档数
            $skip:V      // 跳过的文档数
            $unwind:V    // 拆分数组文档
        })
  
  * mapReduce
    
        db.runCommand({
              mapreduce: 'users',
              map: function () {
                  emit('aaa' + this.age, 
                       {AAA: this.age + 1000, BBB: 111});
              },
              reduce: function (key, docs) {
                  var r = 0;
                  docs.forEach(function (doc) {
                      r += doc;
                  });
                  return {AAA: r, BBB: 222};
              },
              finalize:function(doc){},
              scope:VAR,           // 可访问的全局变量
              verbose:true|false,  // 显示时间统计信息
              out:'coll',
              query:{},
              sort:{},
              limit:V,

        })
    
    map函数对当前集合的每个文档映射=>返回使用新键对应的文档，
    对同样的键的所有文档生成数组docs，
    reduce函数对键key和数组docs进行聚合操作=>返回修改后的文档。


# db.runCommand db.adminCommand

    db.runCommand({lastError:1}) 打印上次错误
    db.adminCommand({shutdown:1}) 关闭服务器


# INDEX

  * ensureIndex(keys, options)

        db.users.ensureIndex({it:1,tt:-1}, {unique:true,dropDups:true,sparse:true})

            unique          : 唯一索引
            dropDups        : 强制唯一索引，建立唯一文档时，重复文档强制删除
            sparse          : 稀疏索引，字段可以不存在
            expireAfterSecs : TTL过期索引
 
  * dropIndex(index)

        db.users.dropIndex({it:1,tt:-1})

  * getIndexes()

        db.users.getIndexes()

  * system.indexes集合


# COMMAND

  * createCollection(name, options)

        db.createCollection('logs', {capped:true,size:100000,max:100}) **创建固定集合(日志)**

        db.te.ensureIndex({lastUpdated:1}, {expireAfterSecs:60*60*24}) **创建TTL过期索引(会话)，到期文档会删除**

            lastUpdated必须是Date时间
            为了防止活跃会话被删除，会话发生时更新lastUpdated=>当前时间
            事实上，MongoDB每分钟清理一次TTL索引，请按照分钟来设定TTL索引

  * runCommand(obj)

        db.runCommand(collMod:'te.sessions', expireAfterSecs:3600) 修改文档索引属性
