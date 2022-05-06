import std/random
import boxy, windy
import fruit

type
  GorbState* = enum
    NONE
    GATHERING
    WANDERING

  Gorb* = object
    alive*: bool
    position*: Vec2
    target*: Vec2
    state*: GorbState
    wandering_timer*: int
    wandering_direction*: int
    view_range*: int
    energy*: float
    speed*: float

proc process_ai*(gorb: Gorb, fruits: seq[Fruit]): Gorb =
  if gorb.alive:
    var gorb = gorb

    # Do something
    if gorb.state == GorbState.NONE:
      try:
        randomize()
        var found_fruit = @[vec2(1000000000, 100000000)]
        for fruit in fruits:
          if
            fruit.position[0] < gorb.position[0] + gorb.view_range.toFloat() and
            fruit.position[0] > gorb.position[0] - gorb.view_range.toFloat() and
            fruit.position[1] < gorb.position[1] + gorb.view_range.toFloat() and
            fruit.position[1] > gorb.position[1] - gorb.view_range.toFloat()
            :
            found_fruit.add(fruit.position)
        if found_fruit.len() > 1:
          randomize()
          gorb.target = found_fruit[rand(found_fruit.len() - 1)]
          gorb.state = GorbState.GATHERING
      except:
        gorb.state = GorbState.WANDERING

    # move
    if gorb.state == GorbState.GATHERING:
      var fruit_exists = false
      for fruit in fruits:
        if fruit.position == gorb.target:
          fruit_exists = true
          break

      if fruit_exists:
        if gorb.target[0] > gorb.position[0]:
          gorb.position[0] += gorb.speed
        if gorb.target[0] < gorb.position[0]:
          gorb.position[0] -= gorb.speed
        if gorb.target[1] > gorb.position[1]:
          gorb.position[1] += gorb.speed
        if gorb.target[1] < gorb.position[1]:
          gorb.position[1] -= gorb.speed
      else:
        gorb.state = GorbState.NONE
    
    elif gorb.state == GorbState.WANDERING and gorb.wandering_timer <= 0:
      randomize()
      gorb.wandering_direction = rand(1..4)
      randomize()
      gorb.wandering_timer = rand(20..80)
    
    elif gorb.state == GorbState.WANDERING and gorb.wandering_timer > 0:
      if gorb.wandering_direction == 1:
        gorb.position[0] += gorb.speed / 1.5
      elif gorb.wandering_direction == 2:
        gorb.position[0] -= gorb.speed / 1.5
      elif gorb.wandering_direction == 3:
        gorb.position[1] += gorb.speed / 1.5
      elif gorb.wandering_direction == 4:
        gorb.position[1] -= gorb.speed / 1.5
      gorb.wandering_timer -= 1
  
    gorb.energy -= 0.1

    if gorb.energy <= 0.0:
      gorb.alive = false
      echo "a gorb has died at (", gorb.position[0].round(), ",", gorb.position[1].round(), ")"
  
    return gorb

  else:
    return gorb

proc detect_eating*(gorb: Gorb, fruits: seq[Fruit]): (Gorb, seq[Fruit]) =
  var gorb = gorb
  var fruits = fruits

  if 
    gorb.state == GorbState.GATHERING and
    gorb.position[0] < gorb.target[0] + 10 and
    gorb.position[0] > gorb.target[0] - 10 and
    gorb.position[1] < gorb.target[1] + 10 and
    gorb.position[1] > gorb.target[1] - 10
    :

    var counter = 0
    var found = false
    for fruit in fruits:
      if fruit.position == gorb.target:
        found = true
        break
      counter += 1
    if found:
      fruits.delete(counter)

    gorb.energy += 10.0
    gorb.state = GorbState.NONE

  return (gorb, fruits)

proc reproduce*(gorb: Gorb, gorbs: seq[Gorb]): (Gorb, seq[Gorb]) =
  if gorb.alive and gorb.energy > 200:
    var gorb = gorb
    var gorbs = gorbs

    randomize()
    let transfer_amount = rand(60..140).toFloat()

    gorb.energy -= transfer_amount

    randomize()
    gorbs.add(Gorb(
      alive: true,
      position: gorb.position,
      state: GorbState.NONE,
      energy: transfer_amount,
      speed: gorb.speed + rand(-10..10) / 10
    ))

    echo "a child has been born"

    return (gorb, gorbs)
  
  return (gorb, gorbs)