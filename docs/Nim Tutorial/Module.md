export 
--------

    # A.js

    var x* = 1

    proc f*(x : int): int = 
        result = x + 1   

<span>

    # A.js

    var x = 1

    proc f(x : int): int = 
        result = x + 1 

    export x, f

import 
-------

    import A, B

<span>

    import A as AA, B as BB

<span>

    import A except x, B as BB

<span>

    from A as AA import nil              // 强制使用命名空间
    from B as BB import nil              // 强制使用命名空间

<span>

    include fileA, fileB, fileC