import windy, boxy

type
  GorbState* = enum
    NONE
    SLEEPING
    GATHERING
    WANDERING

  Gorb* = object
    id*: int
    leg_1_pos*: Vec2
    leg_2_pos*: Vec2
    previous_position*: Vec2
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
    sleep_requirement*: float
    energy_expenditure*: float
    patience*: int

  Fruit* = object
    position*: Vec2
  
  Tree* = object
    alive*: bool
    position*: Vec2
    life_remaining*: int