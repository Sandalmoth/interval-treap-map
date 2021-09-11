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


# test "scratch":
#   var im: IntervalMap[int, string]
#   im[2..7] = "howdy"
#   im[1..3] = "universe"
#   im[-3..12] = "okay"
#   im[2..7] = "howdy-duplicate"

#   echo im

#   echo im[(-5)..(-5)]
#   echo im[0..0]
#   echo im[1..1]
#   echo im[2..2]
#   echo im[4..4]
#   echo im[8..8]
#   echo im[13..13]
#   echo im[-30..30]

