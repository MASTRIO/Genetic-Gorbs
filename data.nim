import game_objects
import windy

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

var new_gorbs* = gorbs

var fruits* = @[
  Fruit(
    position: vec2(0, 0)
  )
]