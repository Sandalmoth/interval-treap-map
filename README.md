# interval-map
A rudimentary imlplementation of a key-value data structure with intervals for keys. Should be more or less O(log(N)), for most operations, but don't quote me on that.

### Example
```nim
import interval_map

var im: IntervalMap(int, string)

# simple notation for including a value
im[1..5] = "hello"
im[3..6] = "world"

# can also include like this
# which provides a pointer that can be used
# for deleting the element later
var x = im.incl(-3..2, "sharks!")

# querying an interval returns a list of values
discard im[-2..2]
# returnts @["sharks!, "hello"]

# the pointer provided from incl can be used for deletion
im.excl(x)
```
