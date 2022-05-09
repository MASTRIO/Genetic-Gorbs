import windy, boxy

type
  GorbState* = enum
    NONE
    SLEEPING
    GATHERING
    WANDERING

  Gorb* = object
    id*: int
    alive*: bool
    colour_tint*: Color
    is_baby*: bool
    baby_time*: int
    death_timer*: float
    position*: Vec2
    target*: Vec2
    state*: GorbState
    wandering_timer*: int
    wandering_direction*: int
    view_range*: int
    energy*: float
    speed*: float

  Fruit* = object
    position*: Vec2
  
  Tree* = object
    alive*: bool
    position*: Vec2
    life_remaining*: int