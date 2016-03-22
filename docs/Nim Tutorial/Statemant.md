
    let x:string = readLine(stdin)

<span>

    if x == "":
        echo("---   ---")
    elif x == "x":
        echo("--- x ---")
    else:
        echo("Hi, ", x, "!")

<span>

    when system.hostOS == "windows":     // #ifdef，编译器评估 
        echo("running on Windows!")
    elif system.hostOS == "linux":
        echo("running on Linux!")
    elif system.hostOS == "macosx":
        echo("running on Mac OS X!")
    else:
        echo("unknown operating system")

<span>

    case x
    of "":
        echo("---   ---")
    of "x":
        echo("--- x ---")
    of "o", "i":
        echo("Hi, ", x, "!")
    else:
        discard

<span>

    while name == "":
        echo("---   ---")
        name = readLine(stdin)

<span>

    var x = [1, 2, 3]

    for i in 0..9:
        echo(i)
    for i in countup(0, 9):
        echo(i)
    for i in countdown(9, 0):
        echo(i)   
    for i, value in x:
        echo i, value
    for value in items(x):
        echo value
    for i in low(x)..high(x):
        echo x[i]
    
<span>

    block myblock:
        var x = "hi"
        var y = "hello"
    echo(x)                              // ERROR

<span>

    const y = (var x = 1; for i in 1..6: x *= i; x)
