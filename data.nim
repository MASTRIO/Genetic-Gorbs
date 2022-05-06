import game_objects
import windy

var next_gorb_id = 0

proc get_new_id*(): int =
  next_gorb_id += 1
  return next_gorb_id

var gorbs* = @[
  Gorb(
    alive: true,
    is_baby: false,
    position: vec2(0, 0),
    state: GorbState.NONE,
    energy: 100.0,
    speed: 3.0
  )
]

var gorb_queue* = @[
  Gorb(
    alive: true,
    is_baby: false,
    position: vec2(0, 0),
    state: GorbState.NONE,
    energy: 100.0,
    speed: 3.0
  )
]

var deletion_queue* = @[
  0
]

var fruits* = @[
  Fruit(
    position: vec2(0, 0)
  )
]