

```

var a = ['a', 'b', 'c']

echo repr a                                         ## ['a', 'b', 'c']
echo repr a.addr()                                  ## ref 0x623f24 --> ['a', 'b', 'c']
echo repr a[0].addr()                               ## ref 0x623f24 --> 'a'
echo repr cast[ptr int8](a[0].addr())               ## ref 0x623f24 --> 97
echo repr cast[ptr char](a[0].addr())               // ref 0x623f24 --> 'a'
echo repr cast[int](a[0].addr())                    ## 6438692
echo repr sizeof(a.addr()[])                        ## 3
echo repr sizeof(a[0].addr())                       ## 8
echo repr sizeof(a[0].addr()[])                     ## 1          
echo repr cast[int](a[0].addr()) + 
          1 * sizeof(a[0].addr()[])                 ## 6438693
echo repr cast[ptr char](cast[int](a[0].addr()) + 
            1 * sizeof(a[0].addr()[]))[]            ## 'b'

template `+`*[T](p: ptr T, offset: int): ptr T =
    cast[ptr type(p[])](cast[ByteAddress](p) +% 
                        offset * sizeof(p[]))

echo repr a[0].addr() + 1                           ## ref 0x623f25 --> 'b'
echo repr a[0].addr() + 2                           ## ref 0x623f26 --> 'c'          
```