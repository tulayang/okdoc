procedure
------------

```
proc toString(x : int) : string =
    result = $x

proc toString(x : bool) : string =
    if x: result = "true"
    else: result = "false"
 
echo toString 1
echo toString true
```

operator
----------

只允许前缀 $a、中缀 a + b 操作符


```
+ - * / % < > = @ $ ~ & ! ? ^ . \ |
```

<span>

```
proc `.`(x : int) : string =
    result = $x
 
echo `.`1
```