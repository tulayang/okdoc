
    $ ssh -V                                        # 查看 openssh 版本
    openssh-server version >= 4.8p1

1. Add Group

       $ groupadd --gid 1000 box                    # 创建组  
       $ groupdel            box                    # 删除组

2. Add User

   为用户建立的目录应该属于 root 用户，并且是 755 权限。

       $ adduser username                           # 创建用户
                 --gid      1000 
                 --home     /home/sftp/username 
                 --shell    /bin/false

                 * --shell  /bin/false              # 禁止登录 shell    

       $ passwd 123456

       $ chown root:box /home/sftp                  # 必须是 root 拥有的目录
       $ chmod -R 755   /home/sftp        
       
       $ usermod --home /home/sftp/username         # 修改用户
                 username                         

3. Vi /etc/ssh/sshd_config

       Subsystem sftp internal-sftp                 # 指定 sftp 服务使用系统自带的 internal-sftp

       Match Group box                              # 匹配组用户
       # Match User u1, u2                        # 匹配个人用户

       ChrootDirectory /home/sftp                   # 用户的根目录指定到 /home/sftp，%u代表用户名，%h代表主目录

       ForceCommand internal-sftp                   # 指定 sftp 命令
 
       AllowTcpForwarding no                        # 不希望用户使用端口转发

4. Mount File

   需要访问用户 home 目录外的文件时，为用户挂载文件，这样用户可以通过 home 目录访问外面的目录。
   
       mount [-参数] [设备名称] [挂载点] 

       $ mount --bind
               /home/root/manual/xiaoming
               /home/xiaoming/manuals               # 挂载

       $ mount --move 
               /home/xiaoming/manuals
               /home/xiaoming/manuals2              # 移动挂载
               
       $ umount /home/root/manual/xiaoming          # 删除挂载

5. Service Manage

       $ service ssh start
       $ service ssh stop
       $ service ssh restart

6. Connect

       $ sftp username@localhost
       
       $ put /locale /remote                        # 上传
       $ get /remote /locale                        # 下载
       
       $ scp [-pr] [-l 速率] file  [账号@]主机:目录名  # 上传
       $ scp [-pr] [-l 速率] [账号@]主机:file  目录名  # 下载
       
         • -p ：保留原本档案的权限数据；
         • -r ：复制来源为目录时，可以复制整个目录 (含子目录)
         • -l ：可以限制传输的速度，单位为 Kbits/s ，例如 [-l 800] 代表传输速限 100Kbytes/s
       