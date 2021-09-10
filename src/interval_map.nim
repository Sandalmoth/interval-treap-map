
import interval_map/private/lcg


type
  Node*[S, T] = object
    parent, left, right: ptr Node[S, T]
    priority: int
    interval: Slice[S]
    rightmost: S # value of the rightmost child interval edge
    value*: T

  IntervalMap*[S, T] = object
    root: ptr Node[S, T]
    counter: int
    rng: Lcg


proc toString[S, T](node: ptr Node[S, T]): string =
  if node.isNil:
    return
  result = '[' & $node.interval.a & ' ' & $node.left.toString() & ' ' &
                 $node.value & ':' & $node.priority & ' ' &
                 $node.right.toString() & ' ' & $node.interval.b & ']'


proc `$`*[S, T](im: IntervalMap[S, T]): string =
  im.root.toString()


proc len*[S, T](im: IntervalMap[S, T]): int =
  im.counter


proc seed*[S, T](im: var IntervalMap[S, T], seed: uint64) =
  ## Seed the internal random number generatior
  ## Note that the generator automatically seeds itself
  ## using times.getTime() upon first incl() operation
  im.rng.seed(seed)


proc rotateLeft[S, T](im: var IntervalMap[S, T], u: ptr Node[S, T]) =
  # FIXME implement handilng rightmost in this
  let w = u.right
  w.parent = u.parent
  if not w.parent.isNil:
    if w.parent.left == u:
      w.parent.left = w
    else:
      w.parent.right = w
  u.right = w.left
  if not u.right.isNil:
    u.right.parent = u
  u.parent = w
  w.left = u
  if u == im.root:
    im.root = w
    w.parent = nil


proc rotateRight[S, T](im: var IntervalMap[S, T], u: ptr Node[S, T]) =
  # FIXME implement handilng rightmost in this
  let w = u.left
  w.parent = u.parent
  if not w.parent.isNil:
    if w.parent.left == u:
      w.parent.left = w
    else:
      w.parent.right = w
  u.left = w.right
  if not u.left.isNil:
    u.left.parent = u
  u.parent = w
  w.right = u
  if u == im.root:
    im.root = w
    w.parent = nil


proc `[]=`*[S, T](im: var IntervalMap[S, T], key: Slice[S], val: sink T) =
  ## Insert value ``val`` at interval ``key``
  let node: ptr Node[S, T] = create(Node[S, T])
  node.value = val
  node.interval = key
  node.priority = im.rng.rand().int

  if im.root.isNil:
    im.root = node
    inc im.counter
    return

  # tree is not empty, find correct position
  # ordering is based on lower bound of interval
  var walk = im.root
  while true:
    if cmp(node.interval.a, walk.interval.a) < 0:
      if walk.left.isNil:
        walk.left = node
        node.parent = walk
        break
      else: walk = walk.left
    else:
      if walk.right.isNil:
        walk.right = node
        node.parent = walk
        break
      else: walk = walk.right

  # preserve heap property of the priority through rotations
  # (this defines a treap)
  while not node.parent.isNil and node.parent.priority > node.priority:
    if node.parent.right == node:
      im.rotateLeft(node.parent)
    else:
      im.rotateRight(node.parent)
  if node.parent.isNil:
    im.root = node

  inc im.counter


proc `[]`*[S, T](im: IntervalMap[S, T], key: Slice[S]): seq[T] =
  discard




