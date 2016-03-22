条件编译
--------

```
#[cfg(feature = "foo")]                
mod foo {
}

$ cargo build --features "foo"

or

$ rustc --cfg feature="foo"
```

<span>

```
#[cfg("foo")]                
mod foo {
}
```

<span>

```
#[cfg(any(unix, windows))]
#[cfg(all(unix, target_pointer_width = "32"))]
#[cfg(not(foo))]

```

or

```
// Cargo.toml

[features]
# no features by default
default = ["foo"]

# The “secure-password” feature depends on the bcrypt package.
secure-password = ["bcrypt"]

$ cargo build
```


