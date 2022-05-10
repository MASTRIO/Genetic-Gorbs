import std/random
import boxy, windy
import game_objects
import data

proc process_ai*(gorb: Gorb): Gorb =
  if gorb.alive:
    var gorb = gorb

    # Age baby
    if gorb.is_baby:
      gorb.baby_time -= 1
      if gorb.baby_time <= 0:
        gorb.is_baby = false

    # Go to sleep
    if gorb.state != GorbState.SLEEPING and not is_day and (gorb.energy >= gorb.sleep_requirement):
      gorb.state = GorbState.SLEEPING
    elif gorb.state == GorbState.SLEEPING and is_day:
      gorb.state = GorbState.NONE

    # Do something
    if gorb.state == GorbState.NONE or gorb.state == GorbState.WANDERING:
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
        else:
          gorb.state = GorbState.WANDERING
      except:
        gorb.state = GorbState.WANDERING

    # move
    if gorb.state == GorbState.GATHERING:
      if gorb.is_baby:
        gorb.current_speed = gorb.normal_speed / 2
      else:
        gorb.current_speed = gorb.normal_speed

      var fruit_exists = false
      for fruit in fruits:
        if fruit.position == gorb.target:
          fruit_exists = true
          break

      if fruit_exists:
        if gorb.target[0] > gorb.position[0]:
          gorb.position[0] += gorb.current_speed
        if gorb.target[0] < gorb.position[0]:
          gorb.position[0] -= gorb.current_speed
        if gorb.target[1] > gorb.position[1]:
          gorb.position[1] += gorb.current_speed
        if gorb.target[1] < gorb.position[1]:
          gorb.position[1] -= gorb.current_speed
      else:
        gorb.state = GorbState.NONE

    elif gorb.state == GorbState.WANDERING and gorb.wandering_timer <= 0:
      randomize()
      gorb.wandering_direction = rand(1..4)
      randomize()
      gorb.wandering_timer = gorb.patience
    
    elif gorb.state == GorbState.WANDERING and gorb.wandering_timer > 0:
      if gorb.is_baby:
        gorb.current_speed = gorb.wandering_speed / 2
      else:
        gorb.current_speed = gorb.wandering_speed

      if gorb.wandering_direction == 1:
        gorb.position[0] += gorb.current_speed
      elif gorb.wandering_direction == 2:
        gorb.position[0] -= gorb.current_speed
      elif gorb.wandering_direction == 3:
        gorb.position[1] += gorb.current_speed
      elif gorb.wandering_direction == 4:
        gorb.position[1] -= gorb.current_speed
      gorb.wandering_timer -= 1
  
    if is_day:
      gorb.energy -= gorb.energy_expenditure
    else:
      gorb.energy -= gorb.energy_expenditure / 8

    # colour tint
    if gorb.energy < 4:
      gorb.colour_tint = color(0, 0.1, 0.9, 1)
    elif gorb.energy < 2:
      gorb.colour_tint = color(0, 0.2, 0.8, 1)
    elif gorb.energy < 3:
      gorb.colour_tint = color(0, 0.2, 0.8, 1)
    elif gorb.energy < 4:
      gorb.colour_tint = color(0, 0.3, 0.7, 1)
    elif gorb.energy < 5:
      gorb.colour_tint = color(0, 0.4, 0.6, 1)
    elif gorb.energy < 10:
      gorb.colour_tint = color(0, 0.5, 0.5, 1)
    elif gorb.energy < 20:
      gorb.colour_tint = color(0, 0.6, 0.4, 1)
    elif gorb.energy < 30:
      gorb.colour_tint = color(0, 0.7, 0.3, 1)
    elif gorb.energy < 50:
      gorb.colour_tint = color(0, 0.8, 0.2, 1)
    else:
      gorb.colour_tint = color(0, 1.0, 0.0, 1)

    # The part that makes them dead :) uwu
    if gorb.energy <= 0.0:
      gorb.alive = false
      gorb.death_timer = 1
      echo "a gorb has died at (", gorb.position[0].round(), ",", gorb.position[1].round(), ")"
  
    return gorb
  else:
    var gorb = gorb

    gorb.death_timer -= 0.001
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
  if gorb.alive and not gorb.is_baby and gorb.energy > 350:
    var gorb = gorb

    randomize()
    let transfer_amount = rand(60..140).toFloat()

    gorb.energy -= transfer_amount

    randomize()
    gorb_queue.add(Gorb(
      id: get_new_id(),
      alive: true,
      is_baby: true,
      baby_time: rand(1000..5000),
      position: gorb.position,
      state: GorbState.NONE,
      energy: transfer_amount,
      normal_speed: gorb.normal_speed + (rand(-5..5) / 10).round(),
      wandering_speed: gorb.wandering_speed + (rand(-5..5) / 10).round(),
      view_range: gorb.view_range + rand(-15..15),
      sleep_requirement: gorb.sleep_requirement + rand(-10..10).toFloat(),
      energy_expenditure: gorb.energy_expenditure + rand(-0.05..0.05),
      patience: gorb.patience + rand(-10..10)
    ))

    echo "a child has been born at (", gorb.position[0].round(), ",", gorb.position[1].round(), ")"

    return gorb
  
  return gorb

proc process_legs*(gorb: Gorb): Gorb =
  var gorb = gorb
  if gorb.previous_position != gorb.position:
    if gorb.previous_position[0] < gorb.position[0]:
      gorb.leg_1_pos[0] -= gorb.current_speed
      gorb.leg_2_pos[0] -= gorb.current_speed
    elif gorb.previous_position[0] > gorb.position[0]:
      gorb.leg_1_pos[0] += gorb.current_speed
      gorb.leg_2_pos[0] += gorb.current_speed
    if gorb.previous_position[1] < gorb.position[1]:
      gorb.leg_1_pos[1] -= gorb.current_speed
      gorb.leg_2_pos[1] -= gorb.current_speed
    elif gorb.previous_position[1] > gorb.position[1]:
      gorb.leg_1_pos[1] += gorb.current_speed
      gorb.leg_2_pos[1] += gorb.current_speed
    
    gorb.previous_position = gorb.position
  
  if gorb.leg_1_pos[0] <= 32:
    gorb.leg_1_pos[0] = 18
  elif gorb.leg_1_pos[0] >= 64:
    gorb.leg_1_pos[0] = 18
  if gorb.leg_1_pos[1] <= 0:
    gorb.leg_1_pos[1] = 20
  elif gorb.leg_1_pos[1] >= 32:
    gorb.leg_1_pos[1] = 20
  
  if gorb.leg_2_pos[0] <= 32:
    gorb.leg_2_pos[0] = 46
  elif gorb.leg_2_pos[0] >= 64:
    gorb.leg_2_pos[0] = 46
  if gorb.leg_2_pos[1] <= 0:
    gorb.leg_2_pos[1] = 20
  elif gorb.leg_2_pos[1] >= 32:
    gorb.leg_2_pos[1] = 20

  return gorb