## Painter

import flippy, chroma

import sequtils, sugar, algorithm, math

type
  Pixel = tuple[x, y: int; color: ColorRGBA]
  Kernel = array[3*3, Pixel]

iterator kernels(img: Image): Kernel =
  for y in 1..<(img.height - 1):
    for x in 1..<(img.width - 1):
      var k: Kernel
      for i in -1..1:
        for j in -1..1:
          k[3*(i+1) + (j+1)] = (x+i, y+j, img.getRgba(x+i, y+j))
      yield k

proc diff(c1, c2: Pixel): int =
  (c1.color.r.int - c2.color.r.int)^2 +
  (c1.color.g.int - c2.color.g.int)^2 +
  (c1.color.b.int - c2.color.b.int)^2 +
  (c1.color.a.int - c2.color.a.int)^2

proc get_dom_pixs(k: Kernel): seq[Pixel] =
  var s = (@k).sortedByIt(it.diff(k[0])) # Sort all of them by their dist to a random node (the pode)
  if s[0].diff(s[^1]) == 0: return s

  result.add(s.pop()) # Get the node furthest from the pode (the antipode)
  while s[^1].diff(result[0]) < s[^1].diff(s[0]): # if a node is closer to the antipode than the pode
    result.add(s.pop()) # Add it to the result
  if s.len > (k.len div 2): return s # if we have a majority in `s` return `s`