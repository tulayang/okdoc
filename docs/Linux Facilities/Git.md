
## Install (安装)

    $ sudo aptitude install git

## Basic Compose (基础操作)

http://www.liaoxuefeng.com/wiki/0013739516305929606dd18361248578c67b8067c8c017b000
https://marklodato.github.io/visual-git-guide/index-zh-cn.html#basic-usage

    $ git init                                         // 初始化文件系统
    $ git add . -A                                     // 添加文件列表
    $ git commit -m 'let commit'                       // 提交文件到工作缓冲区
    $ git rm -r --cached .                             // 清除缓冲区

## Remote Repositories (远程仓库)

    $ git remote add                                   // 添加remote快捷方式
          orign https://github.com/username/test.git 
    $ git remote                                       // 查看远程仓库, 加-v选项可以查看详细信息
    $ git remote rm orign                              // 删除远程仓库
    $ git push -u orign master                         // 本地分支推送到远程的仓库, 
                                                       // 本地master分支与远程的master分支同步
    $ git push -f orign master                         // 强制推送，不管远程仓库与本地文件是否文件一致

## 分支

* master                                         // 主分支，发布最新版本使用master分支
* develop                                        // 开发分支，团队中所有人此分支上开发
* bug                                            // 在本地使用来修复bug，一般不需推送远程仓库中
* feature                                        // 是否需要推送到远程，要看是不是有几个人合作开发新功能
* release                                        // 是系统管理，推送或抓取的分支，一般与开发人员无关
* other                                          // 按需求分配

cmd:

    $ git branch   dev1.0.1                            // 创建分支
    $ git checkout dev1.0.1                            // 切换到分支
    $ git checkout  -b dev1.0.1                        // 创建并切换分支上
    $ git checkout  --orphan dev1.0.1                  // 创建并切换一个没有历史记录的空分支上
    $ git merge    dev                                 // 合并指定分支到当前分支
    $ git branch                                       // 列出本地分支
    $ git branch   -a                                  // 列出所有分支
    $ git branch   -r                                  // 列出远程分支
    $ git branch   -m | -M oldbranch newbranch         // 重命名分支，如果newbranch名字分支已经存在，
                                                       // 则需要使用-M强制重命名，否则，使用-m进行重命名。
    $ git branch   -d | -D branchname                  // 删除branchname分支
    $ git branch   -d   -r branchname                  // 删除远程branchname分支
    
    $ git pull origin next:master

## Tag (标签)

    $ git tag                                          // 列出标签
    $ git tag v0.0.1                                   // 添加标签
    $ git tag v0.0.1  ea3767a                          // 添加标签，指定提交号
    $ git tag 3628164 -a v0.0.1 -m "it 0.01"           // 添加带有注释的标签
    $ git tag v0.0.1  -d                               // 删除标签

## Log (日志管理)

    $ git status                                       // 显示工作树变化
    $ git log    [--pretty=oneline]                    // 显示提交日志
                 [--abbrev-commit]                     
    $ git reflog                                       // 显示工作日志
    $ git show                                         // 显示所有的提交
    $ git show   v0.0.1                                // 显示标签所在的提交
    $ git diff   HEAD | BRANCH                         // 显示两次提交之间的变动

## Head History (回退)

    $ git reset --hard HEAD^                           // 回退到上一个版本(--hard包括工作树)
    $ git reset --hard 3628164                         // 回退到特定的提交号(--hard包括工作树) 

    $ git checkout -- abc.js                           // 恢复工作树和索引内容中的文件到当前分支提交
    $ git checkout HEAD abc.js                         // 恢复工作树和索引内容到提交号(并且换到提交号)
    $ git checkout BRANCH                              // 恢复工作树和索引内容到分支(并切换到分支)

## Git 工作流指南

[Git 工作流指南：Pull Request工作流](http://blog.jobbole.com/76854/)
