Array::rand = ->
  this[Math.round(Math.random() * (@length - 1))]

Array::cw = ->
  temp = []
  y = @length - 1

  while y >= 0
    x = 0

    while x < this[y].length
      temp[x] = []  unless temp[x]
      temp[x][y] = this[@length - 1 - y][x]
      x++
    y--
  temp

Array::copy = ->
  copy = []
  i = 0

  while i < @length
    copy[i] = (if this[i] instanceof Array then this[i].copy() else this[i])
    i++
  copy

Array::exist = -> # arguments
  a = this
  i = 0

  while i < arguments.length
    return false  unless arguments[i] >= 0 and arguments[i] < a.length
    if a[arguments[i]] instanceof Array
      a = a[arguments[i]]
    else
      return true  if i >= arguments.length - 1
      return false
    i++
  true
