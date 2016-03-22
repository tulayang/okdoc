
## Docker daemon

docker daemon 的启动脚本位于 */etc/init.d/docker*，其配置文件是 */etc/default/docker*。

* */etc/init.d/docker* 内容：

  ```sh
  export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin

  BASE=docker
  DOCKER=/usr/bin/$BASE
  DOCKER_OPTS=
  . . .

  if [ -f /etc/default/$BASE ]; then
      . /etc/default/$BASE
  fi
  ```

* */etc/default/docker* 内容：

  ```sh
  DOCKER_OPTS="--host 0.0.0.0:5555"  # 设定守护进程监听端口
  ```

