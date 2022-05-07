import std/random
import boxy, windy
import game_objects
import data

proc process_ai*(gorb: Gorb): Gorb =
  #if gorb.is_baby:
  #  echo gorb.state

  if gorb.alive:
    var gorb = gorb

    # Do something
    if gorb.state == GorbState.NONE or gorb.state == GorbState.BORN:
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
      gorb.death_timer = 2000
      echo "a gorb has died at (", gorb.position[0].round(), ",", gorb.position[1].round(), ")"
  
    return gorb
  else:
    var gorb = gorb

    gorb.death_timer -= 1
    if gorb.death_timer <= 0:
      var list_counter = 0
      var found_self = false
      for list_gorb in gorbs:
        if list_gorb.id == gorb.id:
          found_self = true
          break
        list_counter += 1
      if found_self:
        deletion_queue.add(list_counter)

    return gorb

proc detect_eating*(gorb: Gorb): Gorb =
  var gorb = gorb

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

  return gorb

proc try_reproduce*(gorb: Gorb): Gorb =
  if gorb.alive and gorb.energy > 200:
    var gorb = gorb

    randomize()
    let transfer_amount = rand(60..140).toFloat()

    gorb.energy -= transfer_amount

    randomize()
    gorb_queue.add(Gorb(
      id: get_new_id(),
      alive: true,
      is_baby: true,
      position: gorb.position,
      state: GorbState.NONE,
      energy: transfer_amount,
      speed: gorb.speed + (rand(-10..10) / 10).round()
    ))

    echo "a child has been born at (", gorb.position[0].round(), ",", gorb.position[1].round(), ")"

    return gorb
  
  return gorb