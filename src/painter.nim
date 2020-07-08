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