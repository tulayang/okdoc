
## Linux 风格的链表

```nim
# 
# Linux stype link list
#

type
  ListNode = ptr ListNodeObj
  ListNodeObj = object
    next: ListNode
    prev: ListNode

template offsetOf(typ: typedesc, member: expr): ByteAddress =
  let zero = cast[typ](ByteAddress(0))
  cast[ByteAddress](addr(zero.member))

template containerOf(x: pointer, typ: typedesc, member: expr): expr =
  let it = x
  let containerAddr = cast[ByteAddress](it) - offsetOf(typ, member)
  cast[typ](containerAddr)

proc initListHead(head: ListNode) {.inline.} =
  head.next = head
  head.prev = head

proc add(prev, next, x: ListNode) {.inline.} =
  prev.next = x
  next.prev = x
  x.next = next
  x.prev = prev

proc add(head, x: ListNode) {.inline.} =
  add(head, head.next, x)

proc addTail(head, x: ListNode) {.inline.} =
  add(head.prev, head, x)

proc del(prev, next: ListNode) {.inline.} =
  next.prev = prev
  prev.next = next

proc del(x: ListNode) {.inline.} =
  del(x.prev, x.next)
  x.next = nil
  x.prev = nil

proc replace(old, x: ListNode) {.inline.} =
  old.next.prev = x
  old.prev.next = x
  x.next = old.next
  x.prev = old.prev
  old.next = nil
  old.prev = nil

proc isEmpty(head: ListNode): bool {.inline.} =
  head.next == head

iterator nodes(head: ListNode): ListNode {.inline.} =
  var node = head.next
  while true:
    var next = node.next
    if node == head: 
      break
    yield node
    node = next

iterator bknodes(head: ListNode): ListNode {.inline.} =
  var node = head.prev
  while true:
    var prev = node.prev
    if node == head: 
      break
    yield node
    node = prev

when isMainModule:
  type
    List = object
      head: ListNodeObj

    Data = object
      node: ListNodeObj
      value: int

  proc testHead() =   
    var list = List()
    initListHead(addr(list.head))

    assert isEmpty(addr(list.head)) == true

    for i in 0..9:
      var data = create(Data)
      data.value = i
      add(addr(list.head), addr(data.node))
    
    var m = 9
    for node in nodes(addr(list.head)):
      assert containerOf(node, ptr Data, `node`).value == m
      dec(m)

    var n = 0
    for node in bknodes(addr(list.head)):
      assert containerOf(node, ptr Data, `node`).value == n
      inc(n)

    assert isEmpty(addr(list.head)) == false

    for node in nodes(addr(list.head)):
      del(node)
      dealloc(containerOf(node, ptr Data, `node`))

    assert isEmpty(addr(list.head)) == true

  proc testTail() =
    var list = List()
    initListHead(addr(list.head))

    assert isEmpty(addr(list.head)) == true

    for i in 0..9:
      var data = create(Data)
      data.value = i
      addTail(addr(list.head), addr(data.node))
    
    var m = 0
    for node in nodes(addr(list.head)):
      assert containerOf(node, ptr Data, `node`).value == m
      inc(m)

    var n = 9
    for node in bknodes(addr(list.head)):
      assert containerOf(node, ptr Data, `node`).value == n
      dec(n)

    assert isEmpty(addr(list.head)) == false

    for node in bknodes(addr(list.head)):
      del(node)
      dealloc(containerOf(node, ptr Data, `node`))

    assert isEmpty(addr(list.head)) == true

  testHead()
  testTail()
```

## 完全二叉树

```nim
type
  LeafList = object
    head: ListNodeObj

  LeafData = object
    node: ListNodeObj
    value: TreeNode

  TreeNode = ptr TreeNodeObj
  TreeNodeObj = object
      parent: TreeNode
      left: TreeNode
      right: TreeNode
      value: int

  Tree = ptr TreeObj
  TreeObj = object
      root: TreeNode
      size: int
      leafs: LeafList

proc initLeafList(): LeafList = discard

proc push(L: var LeafList, value: TreeNode) = 
  var leaf = create(LeafData)
  leaf.value = value
  addTail(addr(L.head), addr(leaf.node))

proc pop(L: var LeafList) =
  var last = L.head.prev
  del(last)
  dealloc(containerOf(last, ptr LeafData, `node`))

proc unshift(L: var LeafList, value: TreeNode) =
  var leaf = create(LeafData)
  leaf.value = value
  add(addr(L.head), addr(leaf.node))

proc shift(L: var LeafList) =
  var first = L.head.next
  del(first)
  dealloc(containerOf(first, ptr LeafData, `node`))

proc destroy(L: var LeafList) =
  for node in nodes(addr(L.head)):
    del(node)
    dealloc(containerOf(node, ptr LeafData, `node`))

proc isEmpty(L: var LeafList): bool =
  isEmpty(addr(L.head))

proc first(L: var LeafList): TreeNode =
  containerOf(L.head.next, ptr LeafData, `node`).value

proc createTreeNode(value: int): TreeNode =
  result = create(TreeNodeObj)
  result.value = value

proc createTree(): Tree =
  result = create(TreeObj)
  result.leafs = initLeafList()
  initListHead(addr(result.leafs.head))

proc add(tree: Tree, node: TreeNode) =
  if isEmpty(tree.leafs):
    # 置为根节点
    tree.root = node
    node.parent = node
  else:
    # 提取保存的第一个叶子，它此时最多只有一个子节点。
    # 当该叶子左右节点填满后，将其从叶记录中删除，
    # 移动到下一个叶子节点。
    var firstLeaf = first(tree.leafs)
    assert isNil(firstLeaf.right)
    if isNil(firstLeaf.left):
      firstLeaf.left = node
    else:
      firstLeaf.right = node
    node.parent = firstLeaf

proc swap(tree: Tree, node: TreeNode) =
  var 
    root = tree.root
    left = node.left
    right = node.right

  if root.left == node:
    node.left = root
    node.right = root.right
    if root.right != nil:
      root.right.parent = node
  else:
    node.left = root.left
    node.right = root
    if root.left != nil:
      root.left.parent = node

  if left != nil:
    left.parent = root
  if right != nil:
    right.parent = root

  node.parent = node
  root.parent = node
  root.left = left
  root.right = right
  tree.root = node

proc swap(curr, node: TreeNode) =
  var 
    parent = curr.parent
    left = node.left
    right = node.right

  if parent.left == curr:
    parent.left = node
  else:
    parent.right = node

  if curr.left == node:
    node.left = curr
    node.right = curr.right
    if curr.right != nil:
      curr.right.parent = node
  else:
    node.left = curr.left
    node.right = curr
    if curr.left != nil:
      curr.left.parent = node

  if left != nil:
    left.parent = curr
  if right != nil:
    right.parent = curr

  node.parent = parent
  curr.parent = node
  curr.left = left
  curr.right = right

proc sortTail(tree: Tree, node: TreeNode, last: var TreeNode) =
  var x = node
  var chglast = false
  last = node
  while true:
    var parent = x.parent
    if x.value < parent.value:
      if parent == tree.root:
        swap(tree, x)
      else:
        swap(parent, x)
      if not chglast:
        last = parent
        chglast = true
    else:
      break
    if x == tree.root:
      break

proc changeLeafs(tree: Tree, last: TreeNode) =
  if not isEmpty(tree.leafs):
    if last.parent != first(tree.leafs):
      shift(tree.leafs)
      unshift(tree.leafs, last.parent)
      push(tree.leafs, last)
    else:
      push(tree.leafs, last)
  else:
    push(tree.leafs, last)

  var firstLeaf = first(tree.leafs)
  if not isNil(firstLeaf.left) and not isNil(firstLeaf.right):
    shift(tree.leafs)
    var firstLeaf = first(tree.leafs)

proc add(tree: Tree, value: int) =
  var node = createTreeNode(value)
  var last: TreeNode
  add(tree, node)
  sortTail(tree, node, last)
  changeLeafs(tree, last)

proc print(tree: Tree) = 
  var list: seq[TreeNode] = @[tree.root]
  var i = 0
  while i < len(list):
    echo list[i].value
    if list[i].left != nil:
      add(list, list[i].left)
    if list[i].right != nil:
      add(list, list[i].right)
    inc(i)
  
when isMainModule:
  #
  # 1 2 3 4 5 6 7 8 9
  #  
  #         1
  #       /   \
  #      2      3
  #    /  \    / \
  #   4    5  6   7
  #  / \  / \ 
  # 8   9 10 11
  #
  var tree = createTree()
  add(tree, 1)
  add(tree, 2)
  add(tree, 3) 
  add(tree, 4)
  add(tree, 5)
  add(tree, 6)
  add(tree, 7)
  add(tree, 8)
  add(tree, 9)
  print(tree)
  echo "--------------------"
  #
  # 16 1 3 11 6 7 8 9
  #         16
  #       1    3
  # 
  #           1
  #         6    3 
  #       9 11  7 8
  #     16
  #
  var tree2 = createTree()
  add(tree2, 16)
  add(tree2, 1)
  add(tree2, 3) 
  add(tree2, 11)
  add(tree2, 6)
  add(tree2, 7)
  add(tree2, 8)
  add(tree2, 9)
  print(tree2)
```