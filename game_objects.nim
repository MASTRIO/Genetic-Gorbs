import windy

type
  GorbState* = enum
    NONE
    GATHERING
    WANDERING

  Gorb* = object
    alive*: bool
    is_baby*: bool
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