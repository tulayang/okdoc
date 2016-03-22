# 部署经验

## 构建私有 registry mirror

1. 下载 `registry` 镜像，并启动一个容器作为仓库服务：

   ```sh
   $ docker run -d -p 5000:5000 --restart always --name registry registry
   ```
   
   容器 `registry` 运行在 `5000` 端口，假设该主机 IP 地址是 `192.168.1.1`。
   
2. 下载任意 Docker Hub 镜像，重新标签化：

   ```sh
   $ docker pull swarm
   $ docker tag swarm 192.168.1.1:5000/swarm 
   ```
   
   或者
   
   ```sh
   $ docker tag swarm localhost:5000/swarm
   ```
 
3. 推送到私有仓库：

   ```sh
   $ docker push 192.168.1.1:5000/swarm
   ```
   
   或者 
   
   ```sh
   $ docker tag swarm localhost:5000/swarm
   ```
   
4. 其他主机从私有仓库拉取镜像：

   首先，请确保该主机的 Docker Engine daemon 指定了 `--insecure-registry` （不安全通信） 或者 `--registry-mirror` （安全通信，需要 SSL）。在 */etc/default/docker* 文件中添加以下项：
   
   ```?
   DOCKER_OPTS="--host 0.0.0.0:2376 \
                --insecure-registry 192.168.1.1:5000"
   ```
   
   或者
   
   ```?
   DOCKER_OPTS="--host 0.0.0.0:2376 \
                --registry-mirror 192.168.1.1:5000"
   ```
   
   然后，访问私有仓库

   ```sh
   $ docker search 192.168.1.1:5000/swarm
   ```
   
   这样可以采用不经过安全（TLS）验证的 HTTP 请求。如果需要安全验证，请确保持有验证证书，并且这样：
   
   ```sh
   $ docker <ssl flag> pull https://192.168.1.1:5000/swarm
   ```
   
   > 经过实践证明，必须在 Docker Engine daemon 启动时指定 `--insecure-registry` 或 `--registry-mirror`。如果没有这样做，启动之后，通过 `$ docker --insecure-registry 192.168.1.1:5000 pull swarm` 无法访问。

