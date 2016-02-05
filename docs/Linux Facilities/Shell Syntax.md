```
#! /bin/sh                          # 解释器
```

Variable (变量)
-------------------

```
NAME=xiaoming
EMAIL="send ${NAME}@gamil.com"
DAEMON=/usr/bin/redis-server

[ -x $DAEMON ] || exit 0            # test -x $DAEMON || exit 0
[ -x $DAEMON ] && echo OK           # test -x $DAEMON && exit 0

readonly    DAEMON                  # 变量不可变
unset       DAEMON                  # 删除变量

${var}                              # 变量值
${var:-word}                        # 如果 var 为空或已删除(unset)，返回 word，但不改变 var
${var:=word}                        # 如果 var 为空或已删除(unset)，返回 word，并将 var 设置为 word
${var:?message}                     # 如果 var 为空或已删除(unset)，将消息 message 送到标准错误输出
                                    # 可以用来检测变量 var 是否可以被正常赋值
                                    # 若此替换出现在Shell脚本中，那么脚本将停止运行
${var:+word}                        # 如果 var 被定义，那么返回 word，但不改变 var 的值
```

Command (命令)
--------------

```
DATE=`date`
echo "Date is $DATE"                # ⇒ Date is Thu Jul  2 03:59:57 MST 2009

USERS=`who | wc -l`
echo "User: $USERS"                 # ⇒ User: 2 
``` 

Array (一维数组)
----------------

```
USERS[0]="Zara"
USERS[1]="Qadir"
USERS[2]="Mahnaz"
echo "First  : ${NAME[0]}"
echo "Second : ${NAME[1]}"

USERS=("Zara" "Qadir" "Mahnaz")
echo ${#USERS[@]}                   # 长度 3
echo ${#USERS[0]}                   # 长度 4
```

Operator (运算符)
-----------------

```
echo `expr 2 + 2`                   # ⇒ 4
echo `expr 2 - 2`                   # ⇒ 0
echo `expr 2 \* 2`                  # ⇒ 4
echo `expr 2 / 2`                   # ⇒ 1
echo `expr 2 % 2`                   # ⇒ 0
```

Test (判断)
-----------

```
[ 1 -eq 2 ] number
  
    • -eq                           # ==
    • -ne                           # !=
    • -gt                           # >
    • -ge                           # >=
    • -lt                           # <
    • -le                           # <=

[ abc = abc ] string

    • =                             # ==
    • !=                            # !=
    • -z                            # 长度 = 0
    • -n                            # 长度 > 0

[ -x /home/t.js ] file 

    • -e                            # 存在
    • -r                            # 存在 && 可读 
    • -w                            # 存在 && 可写
    • -x                            # 存在 && 可运行
    • -s                            # 存在 && 有字符
    • -d                            # 存在 && 目录
    • -f                            # 存在 && 文件
    • -c                            # 存在 && 字符设备
    • -b                            # 存在 && 块设备

[ -x /home/t.js -a 1 -eq 1 ] && || ! 

    • !                             # !
    • -o                            # ||
    • -a                            # &&
```

Branch (分支)
-------------

```
a=10
b=20

if [ $a == $b ]
then
   echo "a equal b"
elif [ $a -gt $b ]
then
   echo "a greater than b"
elif [ $a -lt $b ]
then
   echo "a less than b"
else
   echo "..."
fi

case $a in
    1)  echo 1
    ;;
    2)  echo 2
    ;;
    3)  echo 3
    ;;
    *)  echo none
    ;;
esac
```

Loop (循环)
------------

```
for n in 1 2 3 4 5 6                              
do                                           
    echo $n                          
done     

i=0
while [ $i -lt 6 ]
do
    i=`expr $i + 1`
    if [ `$i % 2` -eq 0 ]
    then
        break
    fi
done

u=0
until [ ! $u -lt 6 ]
do
   u=`expr $u + 1`
done
```

Function (函数)
----------------

```
f() {
    echo Hello world!
    echo $1                         # 参数 1
    echo $2                         # 参数 2
    echo $#                         # 所有参数的个数
    echo $*                         # 所有参数
    return 1
}

f 1 2
```

Pipe (管道)
------------

command | file

command > file
command < file

```
echo "It is a test" >  /home/my.log  # 输出          
echo "It is a test" >> /home/my.log  # 输出，追加到文件尾部

wc -l               <  users         # 输入
```

Script (嵌入脚本运行)
--------------------

```
.      /home/t.js
source /home/t.js
```

$I (特殊字符)
------------

```
• $$                                # pid
• $0                                # 当前脚本的文件名
• $n                                # 传递给脚本或函数的参数。n 是一个数字，表示第几个参数
                                    # 例如，第一个参数是 $1，第二个参数是 $2
• $#                                # 传递给脚本或函数的参数个数
• $*                                # 传递给脚本或函数的所有参数
• $@                                # 传递给脚本或函数的所有参数。被双引号(" ")包含时，与 $* 稍有不同
• $?                                # 上个命令的退出状态，或函数的返回值
• $$                                # 当前 Shell pid   

# ./test.sh "a" "b" "c" "d"

for var in $*                       # a\nb\nc\nd
do                                  
    echo "$var"                       
done                                

for var in $@                       # a\nb\nc\nd
do                                  
    echo "$var"                     
done                                

for var in "$*"                     # a b c d
do
    echo "$var"
done

for var in "$@"                     # a\nb\nc\nd
do                                                 
    echo "$var"                                    
done                         
```

Escape (转义)
-------------

```
• -e                                # 字符转义
• -n                                # 禁止换行符转义
• -E                                # 不转义

• \\                                # 反斜杠
• \a                                # 警报，响铃 
• \b                                # 退格（删除键）
• \f                                # 换页，将当前位置移到下页开头
• \n                                # 换行
• \r                                # 回车
• \t                                # 水平制表符
• \v                                # 垂直制表符

echo -e "ABC\nD"                    # ⇒ ABCD，字符转义
echo    "ABC\nD"                    # ⇒ ABC\nD
```