    Client    ---> 连接             ---> Server
              <--- 接收公钥          <---                  // 中间人攻击，诱骗密码
    (核对公钥) ---> 发送密码(公钥加密) ---> (密钥解密)
              <--- 登陆成功          <---
              ---> 发送数据(公钥加密) ---> (密钥解密)
              <--- 确认收到          <---


Install
--------

    $ aptitude install ssh                             // 安装 ssh

Configuration
--------------

1. /etc/ssh/ssh_config (客户端)

       Host *  
       //@  是否经过验证代理（如果存在）转发给远程计算机
       //   ForwardAgent no
       //@  是否自动重定向到安全的通道和显示集
       //   ForwardX11 no
       //   ForwardX11Trusted yes
       //@  是否使用基于RSA算法的rhosts的安全验证
       //   RhostsRSAAuthentication no
       //@  是否使用RSA算法进行安全验证
       //   RSAAuthentication yes
       //@  是否使用口令验证
       //   PasswordAuthentication yes  
       //@  是否尝试进行rhosts身份验证。对于安全性要求较高的系统，设置为no
       //   HostbasedAuthentication no
       //   GSSAPIAuthentication no
       //   GSSAPIDelegateCredentials no
       //   GSSAPIKeyExchange no
       //   GSSAPITrustDNS no
       //@  是否批处理模式，一般设为"no"；如果设为"yes"，交互式输入口令的提示将被禁止
       //   BatchMode no
       //@  是否查看客户端的IP地址以防止DNS欺骗。建议设置为"yes"
       //   CheckHostIP yes
       //@  
       //   AddressFamily any
       //   ConnectTimeout 0
       //@  将主机密钥添加到用户的known_hosts文件中，yes | no | ask。
       //@  如果将该选项设置为ask，那么在连接新系统时会询问是否添加主机密钥；
       //@  如果设置为no，就会自动添加主机密钥；如果设置为yes，就要求手工添加主机密钥。
       //@  若将参数设置yes或ask，则当某系统的主机密钥发生改变之后，OpenSSH会拒绝连接到该系统。
       //@  对于安全性要求较高的系统，请将此参数设置为yes或ask。默认为ask
       //   StrictHostKeyChecking ask
       //@  读取用户的RSA安全验证标识
       //   IdentityFile ~/.ssh/identity
       //   IdentityFile ~/.ssh/id_rsa
       //   IdentityFile ~/.ssh/id_dsa
       //@  连接到客户端的端口
       //   Port 22
       //   Protocol 2,1
       //   Cipher 3des
       //   Ciphers aes128-ctr,aes192-ctr,aes256-ctr,arcfour256,arcfour128,aes128-cbc,3des-cbc
       //   MACs hmac-md5,hmac-sha1,umac-64@openssh.com,hmac-ripemd160
       //   EscapeChar ~
       //   Tunnel no
       //   TunnelDevice any:any
       //   PermitLocalCommand no
       //   VisualHostKey no
       //   ProxyCommand ssh -q -W %h:%p gateway.example.com
       //   RekeyLimit 1G 1h
            SendEnv LANG LC_*
       //@  是否将文件~/.ssh/known_hosts中的主机名和地址进行散列
            HashKnownHosts yes
            GSSAPIAuthentication yes
            GSSAPIDelegateCredentials no

2. /etc/ssh/sshd_config (服务器)

       // This is ssh server systemwide configuration file.
       //@  监听端口
            Port 22
       //@  绑定 IP
            ListenAddress 192.168.1.1
       //@  设置包含计算机私人密匙的文件
            HostKey /etc/ssh/ssh_host_key
       //@  服务器密匙的位数
            ServerKeyBits 1024
       //@  如果用户不能成功登录，在断开连接之前服务器等待的时间（以秒为单位）
            LoginGraceTime 600
       //@  在多少秒之后自动重新生成服务器的密匙。在多少秒之后自动重新生成服务器的密匙（如果使用密匙）。重新生成密匙是为了防止用盗用的密匙解密被截获的信息。
            KeyRegenerationInterval 3600
       //@  是否允许root通过ssh登录。这个选项从安全角度来讲应设成"no"。
            PermitRootLogin no
       //@  是否验证的时候是否使用“rhosts”和“shosts”文件
            IgnoreRhosts yes
       //@  是否在进行RhostsRSAAuthentication安全验证的时候忽略用户的"$HOME/.ssh/known_hosts”
            IgnoreUserKnownHosts yes
       //@  是否在接收登录请求之前是否检查用户目录和rhosts文件的权限和所有权。这通常是必要的，因为新手经常会把自己的目录和文件设成任何人都有写权限。
            StrictModes yes
       //@  是否允许X11转发
            X11Forwarding no
       //@  是否在用户登录的时候显示“/etc/motd”中的信息
            PrintMotd yes
       //@  是否在记录来自sshd的消息的时候，是否给出“facility code”
            SyslogFacility AUTH
       //@  是否记录sshd日志消息的层次。INFO是一个好的选择。
            LogLevel INFO
       //@  是否只用rhosts或“/etc/hosts.equiv”进行安全验证已经足够了
            RhostsAuthentication no
       //@  是否允许用rhosts或“/etc/hosts.equiv”加上RSA进行安全验证
            RhostsRSAAuthentication no
       //@  是否允许只有RSA安全验证
            RSAAuthentication yes
       //@  是否允许口令验证
            PasswordAuthentication yes
       //@  是否允许用口令为空的帐号登录
            PermitEmptyPasswords no
       //@  "AllowUsers”的后面可以跟任意的数量的用户名的匹配串，这些字符串用空格隔开。主机名可以是域名或IP地址。
            AllowUsers admin
             
3. /etc/ssh/ssh_known_hosts (保存可信赖的远程主机的公钥)                            
   /home/username/.ssh/known_hosts (保存可信赖的远程主机的公钥)

Create Key
-----------

    $ ssh-keygen  -t rsa -b 2048 -f /home/username/.ssh  // 生成公钥密钥

      ⇒ /home/username./ssh/id_rsa id_rsa.pub            // 使用 RSA 算法 2048 位创建 SSL 公钥、密钥

      • -t 算法: rsa dsa ecdsa
      • -b 密钥位数
      • -f 文件位置
      • -m 转换后的格式: 
           RFC 4716/SSH2 (默认)
           ⇒ RFC4716(RFC 4716/SSH2 public or private key),
              PKCS8(PEM PKCS8 public key)或PEM(PEM public key)

Copy Key
---------

    $ scp /home/username/.ssh/id_rsa.pub 
          usernameM@192.168.1.181:/home/.ssh             # 复制公钥 (需要公钥访问权限)

Service
--------
    
    $ service  start   ssh                               // 启动服务 
    $ service  stop    ssh                               // 关闭服务
 
Connect
--------

    $ ssh -l username 192.168.1.181                      # 连接服务器
    $ ssh username@192.168.1.181                         # 连接服务器
    
      • -p 8000       端口
      • -h localhost  主机
      