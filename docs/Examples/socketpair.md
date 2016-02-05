### Nim

```
import posix

proc CMSG_LEN(length: cuint): cint {.importc, header: "<sys/socket.h>".}

proc socketpair(fds: var array[0..1, cint]): int {.inline.} =
    result = socketpair(AF_UNIX, SOCK_STREAM, 0, fds)

var 
    pipeFds: array[0 .. 1, cint]
    sockFds: array[0 .. 1, cint]

assert socketpair(pipeFds) == 0
assert socketpair(sockFds) == 0

####################### send model ###########################

var 
    sfd = pipeFds[0].SocketHandle()
    sDataBuff = ['\0']
    sIov = [TIOVec(iov_base: sDataBuff[0].addr(), iov_len: 1)]
    sCmsglen = CMSG_LEN(sizeof(SocketHandle).cuint())       # 20
    sCmsg = createU(Tcmsghdr, sCmsglen)
    sMsg = Tmsghdr(msg_name: nil, 
                   msg_namelen: 0,
                   msg_iov: sIov[0].addr(),
                   msg_iovlen: 1,
                   msg_control: sCmsg,
                   msg_controllen: sCmsglen.Socklen())

sCmsg.cmsg_len  = sCmsglen.Socklen()
sCmsg.cmsg_level = SOL_SOCKET
sCmsg.cmsg_type = SCM_RIGHTS
(cast[ptr int](CMSG_DATA(sCmsg)))[] = sockFds[0]

assert sfd.sendmsg(sMsg.addr(), 0) == 1
free(sCmsg)

####################### recv model ###########################

var 
    rfd = pipeFds[1].SocketHandle()
    rDataBuff = ['\0']
    rIov = [TIOVec(iov_base: rDataBuff[0].addr(), iov_len: 1)]
    rCmsglen = CMSG_LEN(sizeof(SocketHandle).cuint())       # 20
    rCmsg = createU(Tcmsghdr, rCmsglen)
    rMsg = Tmsghdr(msg_name: nil, 
                   msg_namelen: 0,
                   msg_iov: rIov[0].addr(),
                   msg_iovlen: 1,
                   msg_control: rCmsg,
                   msg_controllen: rCmsglen.Socklen())

assert rfd.recvmsg(rMsg.addr(), 0) == 1
assert rCmsg.cmsg_len == rCmsglen.Socklen()
assert rCmsg.cmsg_level == SOL_SOCKET
assert rCmsg.cmsg_type == SCM_RIGHTS
echo((cast[ptr int](CMSG_DATA(rCmsg)))[]) 

free(rCmsg)
```

### C

```
#include <sys/socket.h>
#include <stdio.h>
#include <assert.h>
#include <malloc.h>

int main(int argc, char **argv) {
    int pipeFds[1];
    int sockFds[1];

    assert(socketpair(AF_UNIX, SOCK_STREAM, 0, pipeFds) == 0);
    assert(socketpair(AF_UNIX, SOCK_STREAM, 0, sockFds) == 0);

    /********************* send model *********************/

    struct msghdr sMsg;
    struct iovec sIov[1];
    char sDataBuff[1] = "";
    int sCmsglen = CMSG_LEN(sizeof(int));              // 20
    struct cmsghdr *sCmsg = malloc(sCmsglen);

    sIov[0].iov_base = sDataBuff;
    sIov[0].iov_len  = 1;

    sMsg.msg_name = NULL; 
    sMsg.msg_namelen = 0;
    sMsg.msg_iov = sIov;
    sMsg.msg_iovlen = 1;
    sMsg.msg_control = sCmsg;
    sMsg.msg_controllen = sCmsglen;                     // 20

    sCmsg->cmsg_len = sCmsglen;                         // 20
    sCmsg->cmsg_level = SOL_SOCKET;
    sCmsg->cmsg_type  = SCM_RIGHTS;
    *((int *)(CMSG_DATA(sCmsg))) = sockFds[0];

    assert(sendmsg(pipeFds[0], &sMsg, 0) == 1);
    free(sCmsg);

    /********************* recv model *********************/
    
    struct msghdr rMsg;
    struct iovec rIov[1];
    char rDataBuff[1] = "";
    int rCmsglen = CMSG_LEN(sizeof(int));               // 20
    struct cmsghdr *rCmsg = malloc(rCmsglen);

    rIov[0].iov_base = rDataBuff;
    rIov[0].iov_len  = 1;

    rMsg.msg_name = NULL; 
    rMsg.msg_namelen = 0;
    rMsg.msg_iov = rIov;
    rMsg.msg_iovlen = 1;
    rMsg.msg_control = rCmsg;
    rMsg.msg_controllen = rCmsglen;                     // 20

    assert(recvmsg(pipeFds[1], &rMsg, 0) == 1);
    
    assert(rCmsg->cmsg_len == rCmsglen);
    assert(rCmsg->cmsg_level == SOL_SOCKET);
    assert(rCmsg->cmsg_type == SCM_RIGHTS);
    printf("%d\n", *((int *)(CMSG_DATA(rCmsg))));       // 7

    free(rCmsg);
}
```

### C union version

```
#include <sys/socket.h>
#include <stdio.h>
#include <assert.h>

int main(int argc, char **argv) {
    int pipeFds[1];
    int sockFds[1];

    assert(socketpair(AF_UNIX, SOCK_STREAM, 0, pipeFds) == 0);
    assert(socketpair(AF_UNIX, SOCK_STREAM, 0, sockFds) == 0);

    /********************* send model *********************/

    struct msghdr sMsg;
    struct iovec sIov[1];
    char sDataBuff[1] = "";
    struct cmsghdr *sCmsg;
    union {
        struct cmsghdr cm;
        char buff[CMSG_SPACE(sizeof(int))];           // 24
    } sFdBuff;
    
    sIov[0].iov_base = sDataBuff;
    sIov[0].iov_len  = 1;

    sMsg.msg_name = NULL; 
    sMsg.msg_namelen = 0;
    sMsg.msg_iov = sIov;
    sMsg.msg_iovlen = 1;
    sMsg.msg_control = sFdBuff.buff;
    sMsg.msg_controllen = sizeof(sFdBuff.buff);         // 24

    sCmsg = CMSG_FIRSTHDR(&sMsg);
    sCmsg->cmsg_len = CMSG_LEN(sizeof(int));            // 20
    sCmsg->cmsg_level = SOL_SOCKET;
    sCmsg->cmsg_type = SCM_RIGHTS;
    *((int *)(CMSG_DATA(sCmsg))) = sockFds[0];

    assert(sendmsg(pipeFds[0], &sMsg, 0) == 1);

    /********************* recv model *********************/
    
    struct msghdr rMsg;
    struct iovec rIov[1];
    char rDataBuff[1] = "";
    struct cmsghdr *rCmsg;
    union {
        struct cmsghdr cm;
        char buff[CMSG_SPACE(sizeof(int))];             // 24
    } rFdBuff;

    rIov[0].iov_base = rDataBuff;
    rIov[0].iov_len  = 1;

    rMsg.msg_name = NULL; 
    rMsg.msg_namelen = 0;
    rMsg.msg_iov = rIov;
    rMsg.msg_iovlen = 1;
    rMsg.msg_control = rFdBuff.buff;
    rMsg.msg_controllen = sizeof(rFdBuff.buff);         // 24

    assert(recvmsg(pipeFds[1], &rMsg, 0) == 1);

    rCmsg = CMSG_FIRSTHDR(&rMsg);

    assert(rCmsg->cmsg_len == CMSG_LEN(sizeof(int)));
    assert(rCmsg->cmsg_level == SOL_SOCKET);
    assert(rCmsg->cmsg_type == SCM_RIGHTS);
    printf("%d\n", *((int *)(CMSG_DATA(rCmsg))));       // 7
}
```