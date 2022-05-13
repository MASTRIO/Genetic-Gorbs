import std/random, std/strutils
import boxy, opengl, windy
import gorb, data, game_objects, tools, stopwatch

let windowSize = ivec2(1000, 600)
let window = newWindow("mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm", windowSize)
makeContextCurrent(window)
loadExtensions()

let bxy = newBoxy()

var paused = false

var camera_offset = vec2(0, 0)
let CAMERA_SPEED: float = 50

let timer_max = 2
var fruit_spawn_timer = timer_max
var they_are_alive = true

# Load the images.
bxy.addImage("gorb", readImage("assets/gorb/gorb.png"))
bxy.addImage("smol_gorb", readImage("assets/baby/baby_gorb.png"))

bxy.addImage("one_leg_baby", readImage("assets/baby/one_leg_baby.png"))
bxy.addImage("one_leg_gorb", readImage("assets/gorb/one_leg_gorb.png"))

bxy.addImage("legged_gorb", readImage("assets/gorb/gorb_with_legs.png"))

bxy.addImage("ded_gorb", readImage("assets/gorb/ded_gorb_sad.png"))
bxy.addImage("ded_smol_gorb", readImage("assets/baby/ded_baby_pog.png"))

bxy.addImage("sleeping_smol_gorb", readImage("assets/baby/sleepy_baby.png"))
bxy.addImage("sleeping_gorb", readImage("assets/gorb/sleepy_gorb.png"))

bxy.addImage("fruit", readImage("assets/fruit/fruit.png"))

bxy.addImage("tree", readImage("assets/plants/tree.png"))
bxy.addImage("ded_tree", readImage("assets/plants/dead_tree.png"))

for num in 1..100:
  randomize()
  var new_gorb = Gorb(
    id: get_new_id(),
    leg_1_pos: vec2(18, 32),
    leg_2_pos: vec2(46, 32),
    alive: true,
    is_baby: false,
    position: vec2(
      rand(-1000..1000).toFloat(),
      rand(-1000..1000).toFloat()
    ),
    state: GorbState.NONE,
    energy: rand(40..180).toFloat(),
    normal_speed: rand(1..30).toFloat(),
    wandering_speed: rand(1..20).toFloat(),
    view_range: rand(100..200),
    sleep_requirement: rand(80..100).toFloat(),
    reproduction_requirement: rand(300..500).toFloat(),
    energy_expenditure: rand(0.05..0.5).round(),
    patience: rand(60..120)
  )

  randomize()
  for num in 1..rand(1..3):
    randomize()
    new_gorb.quirks.add(QUIRK_LIST[rand(0..(QUIRK_LIST.len() - 1))])
  
  gorbs.add(new_gorb)

for fruit_num in 1..1:
  randomize()
  fruits.add(Fruit(
    position: vec2(
      rand(-1000..1500).toFloat(), #rand(10..toInt(window.size.vec2[0] - 10)).toFloat(),
      rand(-1000..1500).toFloat() #rand(10..toInt(window.size.vec2[1] - 10)).toFloat()
    )
  ))

for tree_num in 1..30:
  randomize()
  trees.add(
    Tree(
      alive: true,
      position: vec2(
        rand(-1500..1500).toFloat(),
        rand(-1500..1500).toFloat()
      ),
      life_remaining: 10000
    )
  )

gorbs.delete(0)

proc update() =
  timer.stop()
  #echo deltatime.secs, "s"
  deltatime = timer.secs * 10

  second_counter += timer.secs
  tenth_sec_counter += timer.secs

  lifetime += timer.secs
  timer.start()

  if tenth_sec_counter >= 0.1:
    tenth_sec_counter -= 0.1

  if second_counter >= 1:
    second_counter -= 1
    time += 1
    fps = frames
    frames = 0

  if not paused:

    # Day / Night cycle
    if time >= 10:
      if is_day:
        is_day = false
      else:
        is_day = true
      time = 0

    # process gorbs
    try:
      var gorb_count = 0
      for gorb in gorbs:
        gorbs[gorb_count] = gorb.process_ai()
        gorbs[gorb_count] = gorb.detect_eating()
        gorbs[gorb_count] = gorb.try_reproduce()
        gorbs[gorb_count] = gorb.process_legs()
        gorb_count += 1
    except: discard

    # Add gorbs from queue
    try:
      var queue_counter = 0
      for gorb in gorb_queue:
        gorbs.add(gorb)
        gorb_queue.delete(queue_counter)
        #echo "added gorb from queue position ", queue_counter
        #echo gorb_queue
        queue_counter += 1
    except: discard

    # Delete discarded gorbs
    try:
      var queue_counter = 0
      for pos in deletion_queue:
        gorbs.delete(pos)
        deletion_queue.delete(queue_counter)
        queue_counter += 1
    except: discard
  
    # Fruit spawning
    if fruit_spawn_timer <= 0:
      randomize()
      fruits.add(Fruit(
        position: vec2(
          rand(-4000..4000).toFloat(), #rand(10..toInt(window.size.vec2[0] - 10)).toFloat(),
          rand(-4000..4000).toFloat() #rand(10..toInt(window.size.vec2[1] - 10)).toFloat()
        )
      ))
      fruit_spawn_timer = timer_max
    else:
      if tenth_sec_counter >= 0.1:
        fruit_spawn_timer -= 1
  
    # Tree fruit spawning
    var tree_counter = 0
    for tree in trees:
      if tree.alive:
        randomize()
        var chance_of_fruit = 0
        if is_day:
          chance_of_fruit = rand(30)
        else:
          chance_of_fruit = rand(150)
        if chance_of_fruit == 0:
          randomize()
          fruits.add(Fruit(
            position: vec2(
              rand((tree.position[0] - 150)..(tree.position[0] + 150)),
              rand((tree.position[1] + 60 - 150)..(tree.position[1] + 60 + 150))
            )
          ))
        
        trees[tree_counter].life_remaining -= 1
        if tree.life_remaining <= 0:
          trees[tree_counter].alive = false

      tree_counter += 1

    # are they dead?
    if they_are_alive:
      var gorbs_alive = 0
      for gorb in gorbs:
        if gorb.alive:
          gorbs_alive += 1
          break
      if gorbs_alive < 1:
        they_are_alive = false
        echo "they are all dead :)"
        echo "the simulation ran for ", lifetime.round(), " seconds or ", lifetime.round() / 60, " minutes or ", lifetime.round() / 60 / 60, " hours"

  # Camera controller
  if window.buttonDown[Button.KeyUp]:
    camera_offset[1] += CAMERA_SPEED * deltatime
  if window.buttonDown[Button.KeyDown]:
    camera_offset[1] -= CAMERA_SPEED * deltatime
  if window.buttonDown[Button.KeyLeft]:
    camera_offset[0] += CAMERA_SPEED * deltatime
  if window.buttonDown[Button.KeyRight]:
    camera_offset[0] -= CAMERA_SPEED * deltatime
  
  if window.buttonPressed[Button.KeySpace]:
    camera_offset = vec2(0, 0)
  
  # Pause control
  if window.buttonPressed[Button.KeyP]:
    if paused:
      paused = false
      echo "unpaused"
    else:
      paused = true
      echo "paused"

  # Commands
  if window.buttonPressed[Button.KeySlash]:
    paused = true
    echo "\nEnter a command:"
    var command_input = readline(stdin)
    var command = command_input.split(".".toRunes())
    
    case command[0]:
    # Check stats command
    of "check":
      case command[1]:
      # Check how many are alive
      of "alive":
        var living_gorbs = 0
        for gorb in gorbs:
          if gorb.alive:
            living_gorbs += 1
        echo "There are ", living_gorbs, " gorbs still alive"
      # Check time
      of "time":
        echo "the time is ", time, " and day is ", is_day
      else:
        echo "ERROR: invalid argument '", command[1], "'"
    # Goto gorb
    of "goto":
      case command[1]:
      # with quirk
      of "quirk":
        for gorb in gorbs:
          if QUIRK_LIST[command[2].parseInt()] in gorb.quirks:
            camera_offset = gorb.position
            paused = true
      else:
        echo "ERROR: invalid argument '", command[1], "'"
    else:
      echo "ERROR: command not recognised"

# Called when it is time to draw a new frame.
proc draw() =
  #let center = window.size.vec2 / 2
  leg_count = 0

  # Start rendering new frame
  bxy.beginFrame(window.size)

  if is_day:
    bxy.drawRect(rect(vec2(0, 0), window.size.vec2), color(1, 1, 1, 1))
  else:
    bxy.drawRect(rect(vec2(0, 0), window.size.vec2), color(0.15, 0.15, 0.15, 1))

  for fruit in fruits:
    if on_screen(fruit.position, window.size.vec2, camera_offset):
      bxy.drawImage("fruit", fruit.position + camera_offset, 0)

  for gorb in gorbs:
    if on_screen(gorb.position, window.size.vec2, camera_offset):
      if gorb.alive:
        if gorb.state != GorbState.SLEEPING:
          if gorb.is_baby:
            if Quirk.ONE_LEGGED in gorb.quirks:
              bxy.drawImage("one_leg_baby", gorb.position + camera_offset, 0, gorb.colour_tint)
            else:
              bxy.drawImage("smol_gorb", gorb.position + camera_offset, 0, gorb.colour_tint)
          else:
            if leg_count < max_legs:
              draw_legs(bxy, gorb.position + camera_offset + vec2(0, 20), gorb.leg_1_pos, gorb.leg_2_pos)
              bxy.drawImage("gorb", gorb.position + camera_offset, 0, gorb.colour_tint)
            else:
              if Quirk.ONE_LEGGED in gorb.quirks:
                bxy.drawImage("one_leg_gorb", gorb.position + camera_offset, 0, gorb.colour_tint)
              else:
                bxy.drawImage("legged_gorb", gorb.position + camera_offset, 0, gorb.colour_tint)
        else:
          if gorb.is_baby:
            bxy.drawImage("sleeping_smol_gorb", gorb.position + camera_offset, 0, gorb.colour_tint)
          else:
            bxy.drawImage("sleeping_gorb", gorb.position + camera_offset, 0, gorb.colour_tint)
      else:
        if gorb.is_baby:
          bxy.drawImage("ded_smol_gorb", gorb.position + camera_offset, 0, color(0.8, 0, 0.05, gorb.death_timer))
        else:
          bxy.drawImage("ded_gorb", gorb.position + camera_offset, 0, color(0.8, 0, 0.05, gorb.death_timer))

  for tree in trees:
    if on_screen(tree.position, window.size.vec2, camera_offset):
      if tree.alive:
        bxy.drawImage("tree", tree.position + camera_offset, 0)
      else:
        bxy.drawImage("ded_tree", tree.position + camera_offset, 0)

  draw_text(bxy, vec2(10, 10), [100, 20], "fps: " & $fps)

  # End frame
  bxy.endFrame()
  window.swapBuffers()
  inc frames

window.onButtonPress = proc(button: Button) =
  if button == MouseLeft:
    for gorb in gorbs:
      if
        window.mousePos[0] > (gorb.position[0] - 30 + camera_offset[0]).toInt() and
        window.mousePos[1] > (gorb.position[1] - 30 + camera_offset[1]).toInt() and
        window.mousePos[0] < (gorb.position[0] + 30 + camera_offset[0]).toInt() and
        window.mousePos[1] < (gorb.position[1] + 30 + camera_offset[1]).toInt()
        :
        echo $gorb
        paused = true
        break

while not window.closeRequested:
  update()
  draw()
  pollEvents()