
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


proc overlaps[S](a, b: Slice[S]): bool =
  (a.a <= b.b) and (a.b >= b.a)


proc toString[S, T](node: ptr Node[S, T]): string =
  if node.isNil:
    return
  let
    left = $node.left.toString()
    right = $node.right.toString()
  result = '[' & $node.interval.a & ' ' & left & ' ' &
                 $node.value & ':' & $node.priority & ' ' &
                 right & ' ' & $node.interval.b & "->" &
                 $node.rightmost & ']'


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
  echo "rotateLeft"
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

  let
    ulr = (if u.left.isNil: S.low else: u.left.rightmost)
    wlr = (if w.left.isNil: S.low else: w.left.rightmost)
    wrr = (if w.right.isNil: S.low else: w.right.rightmost)
  u.rightmost = max(u.interval.b, max(ulr, wlr))
  w.rightmost = max(w.interval.b, max(u.rightmost, wrr))


proc rotateRight[S, T](im: var IntervalMap[S, T], u: ptr Node[S, T]) =
  echo "rotateRight"
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

  let
    urr = (if u.right.isNil: S.low else: u.right.rightmost)
    wrr = (if w.right.isNil: S.low else: w.right.rightmost)
    wlr = (if w.left.isNil: S.low else: w.left.rightmost)
  u.rightmost = max(u.interval.b, max(urr, wrr))
  w.rightmost = max(w.interval.b, max(u.rightmost, wlr))


proc incl*[S, T](
  im: var IntervalMap[S, T], key: Slice[S], val: sink T
): ptr Node[S, T] =
  ## Insert value ``val`` at interval ``key``
  let node: ptr Node[S, T] = create(Node[S, T])
  result = node

  node.value = val
  node.interval = key
  node.rightmost = key.b
  node.priority = im.rng.rand().int

  inc im.counter

  if im.root.isNil:
    im.root = node
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

  # traverse upwards and update the rightmost limits
  walk = node
  while not walk.parent.isNil:
    walk = walk.parent
    walk.rightmost = max(node.rightmost, walk.rightmost)

  # finally, preserve heap property of the priority through rotations
  # (this defines a treap)
  while not node.parent.isNil and node.parent.priority > node.priority:
    if node.parent.right == node:
      im.rotateLeft(node.parent)
    else:
      im.rotateRight(node.parent)
  if node.parent.isNil:
    im.root = node


proc `[]=`*[S, T](im: var IntervalMap[S, T], key: Slice[S], val: sink T) =
    discard im.incl(key, val)


proc getIntersecting[S, T](node: ptr Node[S, T], key: Slice[S]): seq[T] =
  # Recursive internal implementation of operator `[]`
  if node.isNil:
    return

  if overlaps(key, node.interval):
    result.add(node.value)
  if not node.left.isNil and key.a < node.rightmost:
    result = result & getIntersecting[S, T](node.left, key)
  if not node.right.isNil and node.interval.a <= key.b:
    result = result & getIntersecting[S, T](node.right, key)


proc `[]`*[S, T](im: IntervalMap[S, T], key: Slice[S]): seq[T] =
  ## Find all elements that intersect ``key``, and return them in a seq
  getIntersecting(im.root, key)


proc `[]`*[S, T](im: IntervalMap[S, T], key: S): seq[T] =
  ## Find all elements that intersect ``key`` and return them in a seq
  getIntersecting(im.root, (key)..(key))


# proc find*[S, T](im: IntervalMap[S, T], value: T): ptr Node[S, T] =
#   # TODO implement if I need it
#   discard


proc excl*[S, T](im: var IntervalMap[S, T], node: ptr Node[S, T]) =
  ## Remove node in the map
  # first move the node to be a leaf
  var walk = node
  while not (walk.left.isNil and walk.right.isNil):
    if walk.left.isNil:
      im.rotateLeft(walk)
    elif walk.right.isNil:
      im.rotateRight(walk)
    elif walk.left.priority < walk.right.priority:
      im.rotateRight(walk)
    else:
      im.rotateLeft(walk)
    if im.root == walk:
      im.root = walk.parent

  # now remove the leaf
  if walk.parent.left == walk:
    walk.parent.left = nil
    let wprr = (if walk.parent.right.isNil: S.low else: walk.parent.right.rightmost)
    walk.parent.rightmost = max(walk.parent.interval.b, wprr)
  else:
    walk.parent.right = nil
    let wplr = (if walk.parent.left.isNil: S.low else: walk.parent.left.rightmost)
    walk.parent.rightmost = max(walk.parent.interval.b, wplr)

  # TODO fix rightmost

  dec im.counter
  `=destroy`(walk)
  dealloc(walk)



