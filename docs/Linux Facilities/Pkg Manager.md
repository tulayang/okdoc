
包关系
------

   * depend upon  依赖
   * recommend    推荐
   * suggest      建议
   * conflict     冲突


Ubuntu debian
------------- 

[server url: /etc/apt/sources.list (http://mirrors.163.com ftp://ftp.cn.debian.org/)]

1. dpkg 本地安装软件包的，不解决依赖关系

       $ dpkg               -l                       // 显示所有已经安装的Deb包，同时显示版本号以及简短说明
       $ dpkg       package -p                       // 显示软件包的具体信息
       $ dpkg       package -l                       // 搜索软件包
       $ dpkg       package -i                       // 安装软件包
       $ dpkg               -R                       // 安装一个目录下面所有的软件包
       $ dpkg               -r                       // 删除软件包
       $ dpkg               -P                       // 删除一个包和配置信息

2. apt-get 网络安装软件包，解决依赖关系，不删除已经安装无用的软件包

       $ apt-cache  search     package               // 搜索软件包
       $ apt-cache  show       package               // 获取包的相关信息，如说明、大小、版本等
       $ apt-get    install    package               // 安装软件包
       $ apt-get    install    package  --reinstall  // 重新安装
       $ apt-get    install             -f           // 修复安装
       $ apt-get    remove     package               // 删除包
       $ apt-get    remove     package  --purge      // 删除包，包括配置文件等
       $ apt-get    update                           // 更新源
       $ apt-get    upgrade                          // 更新已安装的包
       $ apt-cache  depends    package               // 了解使用该包依赖那些包
       $ apt-cache  rdepends   package               // 查看该包被哪些包依赖
       $ apt-get    build-dep  package               // 安装相关的编译环境
       $ apt-get    source     package               // 下载该包的源代码
       $ apt-get    clean  &&  apt-get  autoclean    // 清理无用的包
       $ apt-get    check                            // 检查是否有损坏的依赖

3. aptitude 网络安装软件包，解决依赖关系，智能删除已经安装无用的软件包会自动查找并安装其所依赖和推荐的若干软件包，当这种自动安装的软件包不再被依赖时，将其删除。当发生依赖错误时，会提出修正的方案供用户选择

       $ aptitude   update                           // 更新源
       $ aptitude   safe-upgrade                     // 以不删除为前提，升级尽量多的软件包
       $ aptitude   full-upgrade                     // 升级所有可能的软件包
       $ aptitude   install       pkg1  pkg2...      // 安装软件包
       $ aptitude   remove        pkg1  pkg2...      // 删除软件包
       $ aptitude   purge         pkg1  pkg2...      // 清除软件包

