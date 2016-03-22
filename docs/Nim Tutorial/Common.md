Throw Error (堆分配内存)
-----------------------

### throw

    var e: ref OSError
    new(e)
    e.msg = "the request to the OS failed"
    raise e

<span>

    raise newException(OSError, "the request to the OS failed")

### try

    var f: File
    if open(f, "talk.nim"):
        try:
            let a = readLine(f)
        except OverflowError : echo "overflow!"
        except ValueError    : echo ""
        except IOError       : echo "IO error!"
        except               :
            echo "Unknown exception!"
            # let e = getCurrentException()
            raise
        finally:
            echo 1
            close(f)
            
