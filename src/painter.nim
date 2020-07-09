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

proc get_direction(pixs: openArray[Pixel]; x0, y0: int): tuple[x, y: float] =
  for (x, y, c) in pixs:
    result.x += float(x - x0)
    result.y += float(y - y0)
  let mag = sqrt(result.x^2 + result.y^2)
  if mag == 0: return (0.0, 0.0)
  result.x /= mag
  result.y /= mag

proc mix(c1: ColorRGBA; r1: float; c2: ColorRGBA; r2: float): ColorRGBA =
  result.r = uint8((c1.r.float * r1) + (c2.r.float * r2))
  result.g = uint8((c1.g.float * r1) + (c2.g.float * r2))
  result.b = uint8((c1.b.float * r1) + (c2.b.float * r2))

proc paint(img: Image): Image =
  result = img
  for i in countup(3, result.data.high, result.channels):
    result.data[i] = 1 # Set all the alpha values to 1 to use as a tracker variable for mixing
  for k in img.kernels:
    let # Get the coords from the center Pixel of the kernel
      x = k[4].x
      y = k[4].y
    let dom_pixs = k.get_dom_pixs()
    let dom_c = dom_pixs[0].color # Get the dominant color in the kernel
    let (dx, dy) = dom_pixs.get_direction(x, y) # Get the gradient of the dominant pixels in the kernel from the kernels center
    for i in -2..2:
      for j in -2..2:
        if abs(dx*(i.float/2) + dy*(j.float/2)) >= 0.9 and result.inside(x+i, y+j): # As long as they dont face away from each other (uses dot product)
          let a = float(result.getRgba(x+i, y+j).a)
          var new_c = mix(img.getRgba(x+i, y+j), 1/2, dom_c, 1/2)
          new_c.a = a.uint8 + 1
          result.putRgba(x+i, y+j, new_c)
  for i in countup(3, result.data.high, result.channels):
    result.data[i] = 255 # Make the image fully opaque

var img = loadImage("img.png").trim().paint()
img.save("heh.png")