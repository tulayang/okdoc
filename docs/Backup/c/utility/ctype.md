```
#include <ctype.h>
```

Character（字符类型）
-------------------


* 0 1 2 3 4 5 6 7 8 9 
* 0 1 2 3 4 5 6 7 8 9 A B C D E F a b c d e f 
* a b c d e f g h i j k l m n o p q r s t u v w x y z 
* A B C D E F G H I J K L M N O P Q R S T U V W X Y Z 
* ! " // $ % & ' ( ) + , - . / : ; < = > ? @ [ \ ] ^ _ ` {  } ~ |
* 图形字符 = 字母 + 数字 + 标点符号                                     
* 空白字符 = 空格符 + 制表符                
* 空格字符 = 制表符 + 换行符 + 垂直制表符 + 换页符 + 回车符 + 空格符  
* 可打印字符 = 字母 + 数字 + 标点符号 + 空格   
* 控制字符  = 在 ASCII 编码中，这些字符的八进制代码是从 000 到 037，以及 177（DEL）

Is (字符检查)
-----------

```
int isdigit (int c)       ⇒  0 | 非0       // ?十进制数字
int isxdigit(int c)       ⇒  0 | 非0       // ?十六进制数字
int isalpha (int c)       ⇒  0 | 非0       // ?字母
int islower (int c)       ⇒  0 | 非0       // ?小写字母
int isupper (int c)       ⇒  0 | 非0       // ?大写字母
int isalnum (int c)       ⇒  0 | 非0       // ?字母数字
int iscntrl (int c)       ⇒  0 | 非0       // ?控制
int isgraph (int c)       ⇒  0 | 非0       // ?图形
int isprint (int c)       ⇒  0 | 非0       // ?可打印
int ispunct (int c)       ⇒  0 | 非0       // ?标点符号
int isspace (int c)       ⇒  0 | 非0       // ?空白
```

To (字符转换)
-----------

```
int tolower (int c)       ⇒  字符          // 字母 -> 小写
int toupper (int c)       ⇒  字符          // 字母 -> 大写
```