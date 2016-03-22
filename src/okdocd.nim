import os, posix

const LockFile = "/var/run/okdocd/okdocd.pid"
let   LockMode = S_IRUSR or S_IWUSR or S_IRGRP or S_IROTH

proc daemon(nochdir, noclose: cint): cint {.importc, header: "unistd.h".}
proc syslog(priority: cint, message: cstring): cint {.importc, header: "syslog.h".}

proc lockfile(fd: cint): cint =
    var lock = Tflock(l_type: cshort(F_WRLCK),
                      l_whence: cshort(SEEK_SET),
                      l_start: Off(0),
                      l_len: Off(0)) 
    fcntl(fd, F_SETLK, addr(lock))

proc running(): bool =
    let fd = open(cstring(LockFile), O_RDWR or O_CREAT, LockMode)
    if fd == -1:
        # TODO: 
        # let error = "can't open " & LockFile & ": " & getCurrentExceptionMsg()
        # syslog(LOG_ERR, cstring(error))
        quit(QuitFailure)
    if lockfile(fd) == -1:
        if cint(osLastError()) in {EACCES, EAGAIN}:
            discard close(fd)
            return true
        # TODO: 
        # let error = "can't lock " & LockFile & ": " & getCurrentExceptionMsg()
        # syslog(LOG_ERR, cstring(error))
        quit(QuitFailure)
    discard ftruncate(fd, Off(0))
    var spid = $getpid()
    discard write(fd, cstring(spid), len(spid))
    false

discard daemon(cint(0), cint(0))

if running():
    # TODO: 
    # let error = "daemon already running"
    # syslog(LOG_ERR, cstring(error))
    quit(QuitFailure)

# TODO:
# sigaction SIGHUP SIGTERM

include okdoc