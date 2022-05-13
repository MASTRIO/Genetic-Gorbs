import boxy, windy, pixie
import data

let font = readFont("assets/fonts/IBMPlexMono-Bold.ttf")

proc on_screen*(object_pos: Vec2, window_size: Vec2, camera_pos: Vec2): bool =
  if
    object_pos[0] > -camera_pos[0] and
    object_pos[1] > -camera_pos[1] and
    object_pos[0] < window_size[0] - camera_pos[0] and
    object_pos[1] < window_size[1] - camera_pos[1]
    :
    return true
  else:
    return false

#proc draw_line*(boxy: Boxy, image_pos: Vec2, start_pos: Vec2, end_pos: Vec2) =
#  image.fill(rgba(0, 0, 0, 0))
#
#  ctx.strokeSegment(segment(start_pos, end_pos))
#  boxy.addImage("line", image)
#  boxy.drawImage("line", image_pos, 0)

proc draw_legs*(boxy: Boxy, image_pos: Vec2, foot_1: Vec2, foot_2: Vec2) =
  let leg = newImage(64, 32)
  let ctx = newContext(leg)
  #leg.fill(rgba(0, 0, 0, 0))

  ctx.strokeSegment(segment(vec2(18, 0), foot_1))
  ctx.strokeSegment(segment(vec2(46, 0), foot_2))

  boxy.addImage("legs", leg)
  boxy.drawImage("legs", image_pos, 0)

  leg_count += 1

proc draw_text*(boxy: Boxy, image_pos: Vec2, image_size: array[2, int], text: string) =
  try:
    let image = newImage(image_size[0], image_size[1])
    
    image.fillText(font, text)
    boxy.addImage("text", image)
    boxy.drawImage("text", image_pos)
  except: discard