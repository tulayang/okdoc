```
type A[T] = object
                name: T

var a = A[string](a: "xiaoming")
echo a

var b: A[string]
b.name = "xiaoming"
echo b
```

<span>

```
proc f*[T](x: T): int = 
    result = x + 1

echo f(1)
```