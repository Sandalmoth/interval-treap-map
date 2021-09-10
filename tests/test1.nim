import unittest

import interval_map


test "free pass":
  check 1 == 1


test "scratch":
  var im: IntervalMap[int, string]
  im[2..7] = "howdy"
  im[1..3] = "universe"

  echo im

  echo im[2..2]
