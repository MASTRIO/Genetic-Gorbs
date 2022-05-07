import windy

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