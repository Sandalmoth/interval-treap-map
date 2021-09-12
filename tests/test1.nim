import unittest

import interval_map


test "free pass":
  check 1 == 1


test "scratch":
  var im: IntervalMap[int, string]
  var loc = im.incl(1..5, "howdy")
  im[2..4] = "howdy"

  echo im
  for i in 0..<7:
    echo i, ' ', im[i]

  im.excl(loc)

  echo im
  for i in 0..<7:
    echo i, ' ', im[i]



