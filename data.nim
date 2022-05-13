import game_objects
import windy, pixie, stopwatch

var frames*: int
var timer*: Stopwatch
var deltatime* = 0.0

var second_counter* = 0.0
var tenth_sec_counter* = 0.0

var fps* = 0
var lifetime* = 0.0

var time* = 0
var is_day* = true

var max_legs* = 0 #! do not set above 0 unless you want to explode :)
var leg_count* = 0

var next_gorb_id = 0

proc get_new_id*(): int =
  next_gorb_id += 1
  return next_gorb_id

var gorbs* = @[
  Gorb(
    alive: false,
    death_timer: 1,
    is_baby: false,
    position: vec2(0, 0),
    state: GorbState.NONE,
    energy: 1.0,
    normal_speed: 3.0
  )
]

var gorb_queue* = @[
  Gorb(
    alive: true,
    is_baby: false,
    position: vec2(0, 0),
    state: GorbState.NONE,
    energy: 100.0,
    normal_speed: 3.0,
    reproduction_requirement: 999999999
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