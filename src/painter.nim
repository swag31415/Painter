## Painter

import flippy, chroma

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