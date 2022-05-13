import windy, boxy

type
  Quirk* = enum
    COMPASSIONATE
    GREEDY
    NOCTURNAL
    SLEEP_DEPRIVED
    FARMER
    CANNIBAL
    ONE_LEGGED

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
    current_speed*: float
    normal_speed*: float
    wandering_speed*: float
    sleep_requirement*: float
    reproduction_requirement*: float
    energy_expenditure*: float
    patience*: int
    quirks*: seq[Quirk]

  Fruit* = object
    position*: Vec2
  
  Tree* = object
    alive*: bool
    position*: Vec2
    life_remaining*: int

const QUIRK_LIST* = [
  Quirk.COMPASSIONATE,
  Quirk.GREEDY,
  Quirk.NOCTURNAL,
  Quirk.SLEEP_DEPRIVED,
  Quirk.FARMER,
  Quirk.CANNIBAL,
  Quirk.ONE_LEGGED,
]

proc `$`*(gorb: Gorb): string {.raises: [].} =
  "/==========================" &
  "\n| alive: " & $gorb.alive &
  "\n| is_baby: " & $gorb.is_baby &
  "\n| state: " & $gorb.state &
  "\n| view range: " & $gorb.view_range &
  "\n| energy: " & $gorb.energy &
  "\n| normal speed: " & $gorb.normal_speed &
  "\n| wandering speed: " & $gorb.wandering_speed &
  "\n| sleep requirement: " & $gorb.sleep_requirement &
  "\n| reproduction requirement: " & $gorb.reproduction_requirement &
  "\n| energy expenditure: " & $gorb.energy_expenditure &
  "\n| patience: " & $gorb.patience &
  "\n| quirks: " & $gorb.quirks &
  "\n\\=========================="