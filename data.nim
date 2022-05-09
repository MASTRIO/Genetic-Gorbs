import game_objects
import windy, pixie

var time* = 0
var is_day* = true

var max_legs* = 10
var leg_count* = 0

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
    energy: 1.0,
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

var trees* = @[
  Tree(
    alive: true,
    position: vec2(0, 0),
    life_remaining: 10000
  )
]