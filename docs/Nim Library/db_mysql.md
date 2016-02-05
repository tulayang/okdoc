Module db_mysql
==================

```
import strutils, mysql  
```

Types
----------

```
TDbConn   = PMySQL                ## 封装了一个数据库连接
TRow      = seq[string]           ## 数据集中的一行。NULL 总是被转换为 empty string。
EDb       = object of IOError     ## 出现数据库错误时，抛出的异常
TSqlQuery = distinct string       ## 一条 SQL 查询字语句
FDb       = object of IOEffect    ## 表示一条数据库操作的 effect
FReadDb   = object of FDb         ## 表示一条数据库读操作的 effect
FWriteDb  = object of FDb         ## 表示一条数据库写操作的 effect
```

Procs
----------

```
proc sql(query: string): TSqlQuery {.noSideEffect, inline, raises: [], tags: [].}
     ## 从字符串构造一条 TSqlQuery。支持用于 raw-string-literal modifier :
     ## sql"update user set counter = counter + 1"
     ## 如果断言关闭，不会做任何事情。如果断言开启，最新版本会检测 string 的语法是否有效。

proc dbError(msg: string) {.noreturn, raises: [EDb], tags: [].}
     ## 抛出一个使用 msg 消息的 EDb 异常。

proc dbQuote(s: string): string {.raises: [], tags: [].}
     ## DB 引用字符串

proc tryExec(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): bool 
            {.tags: [FReadDb, FWriteDb], raises: [].}
     ## 尝试运行查询语句，如果成功返回 true，否则返回 false。

proc exec(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]) 
         {.tags: [FReadDb, FWriteDb], raises: [EDb].}  
     ## 运行查询语句，如果失败抛出 EDb 异常。 

proc getRow(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): TRow 
           {.tags: [FReadDb], raises: [EDb].}
     ## 运行查询语句，获取一行数据。如果查询没有返回任何行，则返回一个每列是空字符串的 TRow 。

proc getAllRows(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): seq[TRow] 
               {.tags: [FReadDb], raises: [EDb].}
     ## 运行查询语句，返回全部的结果数据集。

proc getValue(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): string 
             {.tags: [FReadDb], raises: [EDb].}
     ## 运行查询语句，返回结果数据集的第一行第一列。如果结果数据集没有行，或者是 NULL，返回 "" 。

proc tryInsertId(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): int64 
                {.tags: [FWriteDb], raises: [].}
     ## 运行查询语句（insert），返回生成的 ID，如果错误返回 -1。

proc insertId(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): int64 
             {.tags: [FWriteDb], raises: [EDb].}
     ## 运行查询语句（insert），返回生成的 ID。如果失败抛出 EDb 异常。

proc execAffectedRows(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): int64 
                     {.tags: [FReadDb, FWriteDb], raises: [EDb].}
     ## 运行查询语句（update），返回生效的行的数量。如果失败抛出 EDb 异常。

proc close(db: TDbConn) {.tags: [FDb], raises: [].}
     ## 关闭数据库连接。

proc open(connection, user, password, database: string): TDbConn 
         {.tags: [FDb], raises: [EDb, OverflowError, ValueError].}
     ## 打开一个数据库连接。如果失败抛出 EDb 异常。

proc setEncoding(connection: TDbConn; encoding: string): bool 
                {.tags: [FDb], raises: [].}
     ## 设置数据库连接的编码。如果成功返回 true，否则返回 false。
```

Iterators
------------

```
iterator fastRows(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): TRow 
                 {.tags: [FReadDb], raises: [EDb].}
         ## 运行查询语句，并且迭代结果数据集。非常快，但是有风险: 如果 for-loop-body 运行另一条查询，这些结果
         ## 会是未定义。在 MySQL 中是这样！

iterator rows(db: TDbConn; query: TSqlQuery; args: varargs[string, `$`]): TRow 
             {.tags: [FReadDb], raises: [EDb].}
         ## 同 fastRows，但是较慢，安全。
```