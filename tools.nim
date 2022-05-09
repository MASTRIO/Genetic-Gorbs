import windy, boxy, pixie
import data

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

proc draw_leg*(boxy: Boxy, image_pos: Vec2, foot: Vec2) =
  if leg_count < max_legs:
    try:
      let leg = newImage(32, 32)
      let ctx = newContext(leg)
      #leg.fill(rgba(0, 0, 0, 0))

      ctx.strokeSegment(segment(vec2(17, 0), foot))
      boxy.addImage("line", leg)
      boxy.drawImage("line", image_pos, 0)

      leg_count += 1
    except: discard