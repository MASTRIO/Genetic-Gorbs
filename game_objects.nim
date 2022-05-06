import windy

type
  GorbState* = enum
    NONE
    BORN
    GATHERING
    WANDERING

  Gorb* = object
    id*: int
    alive*: bool
    is_baby*: bool
    death_timer*: int
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