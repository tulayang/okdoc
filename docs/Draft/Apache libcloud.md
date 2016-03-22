# [Apache libcloud](https://libcloud.apache.org/)

Apache libcloud 的代码结构是这样的：

```?
                +-----------------------------------------------------------+
                |    common.base.Response    →  common.base.JsonResponse   |
                |                            →  common.base.XmlResponse    |
                |                            →  ......                     |
                +-----------------------------------------------------------+

                                           ↓ responseCls

                +-----------------------------------------------------------+
                |    common.base.Connection  →  common.base.ConnectionKey  |
                |                            →  ......                     |
                +-----------------------------------------------------------+

                                           ↓ connectionCls
                
                +-----------------------------------------------------------+
                |    common.base.BaseDriver  →  compute.base.NodeDriver    |
                |                            →  ......                     |
                +-----------------------------------------------------------+                               
```

## Response

###: Response

```python
class Response(response: Response, connection: Connection) of object
```

* Module: libcloud.common.base
* Data Type

驱动所使用的基础 HTTP 响应例程，其成员包括：

* `status: int` 响应状态码

* `headers: dict` 响应头

* `body: str` 响应体

* `object: str|Json|Xml` 解析后的响应体

* `error: str` 出现错误时的错误消息

* `connection: Connection` 所依赖的连接对象

* `parse_zero_length_body: bool`

* `parse_body(): str|Json|Xml` 解析响应体

* `parse_error(): str|Json|Xml` 解析错误消息

* `success(): bool` 判断响应状态码是否成功

* `_decompress_response(body: str, headers: dict)` 解压缩响应体（如果响应启用了 deflate 或 gzip 压缩编码）

###: JsonResponse

```python
class JsonResponse(response: Response, connection: Connection) of Response
```

* Module: libcloud.common.base
* Data Type

基于 `Response` 实现、响应体格式化为 JSON，其成员包括：

* `parse_body(): Json` 解析响应体

* `parse_error(): Json` 解析错误消息

###: XmlResponse

```python
class XmlResponse(response: Response, connection: Connection) of Response
```

* Module: libcloud.common.base
* Data Type

基于 `Response` 实现、响应体格式化为 XML，其成员包括：

* `parse_body(): Xml` 解析响应体

* `parse_error(): Xml` 解析错误消息

### 

## Connection

###: Connection

```python
class Connection(secure: bool, host: str, port: int, url: str, timeout: int, proxy_url: str, retry_delay: int, backoff: bool) of object
```

* Module: libcloud.common.base
* Data Type

驱动所使用的基础 HTTP 连接例程，其成员包括：

* `responseCls: Response` 所绑定的响应对象

* `connection: HTTPConnection|HTTPSConnection` 所依赖的 HTTP 响应对象

* `host: str` 主机名，默认 "127.0.0.1"

* `port: int` 端口号，默认 443

* `timeout: int` 超时时间

* `retry_delay: int` 连接失败时，经过 x 秒重新连接

* `backoff: bool`

* `allow_insecure: bool` 是否允许非安全连接，默认 True

* `secure: int` 是否安全连接，值只能是 0 | 1

* `ua: list` 可信任的密钥认证机构

* `context: dict`

* `request_path: str` 请求路径

* `proxy_url: str` 代理路径

* `action: str` 请求方法

* `set_http_proxy(proxy_url: str): void` 设置代理路径

* `set_context(context: dict): void`

* `reset_context(): void`

* `connect(host: str, port: int, base_url: str, **kwargs): HTTPConnection|HTTPSConnection` 连接服务器

* `user_agent_append(token: str)` 

* `request(action: str, params: dict, data: unicode, headers: dict, method: str, raw: bool): Response`

* `morph_action_hook(action: str): str` 为请求路径加入新的内容

* `add_default_params(params: dict): dict` 为默认参数加入新的内容

* `add_default_headers(headers: dict): dict` 为默认请求头加入新的内容

* `pre_connect_hook(params: dict, headers: dict)` 连接前的挂钩函数

* `encode_data(dataa: unicode): unicode` 编码数据

### 

## Driver

###: BaseDriver

```python
class BaseDriver(key: str, secret: str, secure: bool, host: str, port: int, api_version: str, region: str, **kwargs) of object
```

* Module: libcloud.common.base
* Data Type

基础驱动，其成员包括：

* `connectionCls: Connection` 所绑定的连接对象

###: NodeDriver

```python
class NodeDriver(key: str, secret: str, secure: bool, host: str, port: int, api_version: str, region: str, **kwargs) of object
```

* Module: libcloud.compute.base
* Data Type

计算驱动，其成员包括：

* `connectionCls: Connection` 所绑定的连接对象

* `name: str`

* `type: str`

* `port: int`

* `features: dict`

* `list_nodes(): Node`

* `list_sizes(location: NodeLocation): NodeSize`

* `list_locations(): NodeLocation`

* `create_node(**kwargs): Node`

* `deploy_node(**kwargs): void`

* `reboot_node(node: Node): bool`

* `destroy_node(node: Node): bool`

* `list_volumes(): StorageVolume`

* `list_volume_snapshots(volume: StorageVolume): VolumeSnapshot`

* `create_volume(size: int, name: str, location: NodeLocation, snapshot: VolumeSnapshot): StorageVolume`

* `create_volume_snapshot(volume: StorageVolume, name: str): VolumeSnapshot`

* `attach_volume(node: Node, volume: StorageVolume, device: str): bool`

* `detach_volume(volume: StorageVolume): bool`

* `destroy_volume(volume: StorageVolume): bool`

* `destroy_volume_snapshot(snapshot: VolumeSnapshot): bool`

* `list_images(location: NodeLocation): NodeImage`

* `create_image(node: Node, name: str, description: str): NodeImage`

* `delete_image(node_image: NodeImage): bool`

* `get_image(image_id: str): NodeImage`

* `copy_image(source_region: str, node_image: NodeImage, name: str, description: str): NodeImage`

* `list_key_pairs(): list[KeyPair]`

* `get_key_pair(name: str): KeyPair`

* `create_key_pair(name: str): void`

* `import_key_pair_from_string(name: str, key_material: str): KeyPair`

* `import_key_pair_from_file(name: str, key_file_path: str): KeyPair`

* `delete_key_pair(key_pair: KeyPair): void`

* `wait_until_running(nodes: list[Node], wait_period: int, timeout: int, ssh_interface: str, force_ipv4: bool, ex_list_nodes_kwargs: dict): [(Node, ip_addresses)]`
