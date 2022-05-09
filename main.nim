import std/random
import boxy, opengl, windy
import gorb, data, game_objects, tools

let windowSize = ivec2(1000, 600)
let window = newWindow("Genetic gorbs", windowSize)
makeContextCurrent(window)
loadExtensions()

let bxy = newBoxy()

var paused = false

var camera_offset = vec2(0, 0)
let CAMERA_SPEED: float = 10

let timer_max = 2
var fruit_spawn_timer = timer_max
var they_are_alive = true

# Load the images.
bxy.addImage("gorb", readImage("assets/gorb/gorb.png"))
bxy.addImage("smol_gorb", readImage("assets/baby/baby_gorb.png"))

bxy.addImage("ded_gorb", readImage("assets/gorb/ded_gorb_sad.png"))
bxy.addImage("ded_smol_gorb", readImage("assets/baby/ded_baby_pog.png"))

bxy.addImage("sleeping_smol_gorb", readImage("assets/baby/sleepy_baby.png"))
bxy.addImage("sleeping_gorb", readImage("assets/gorb/sleepy_gorb.png"))

bxy.addImage("fruit", readImage("assets/fruit/fruit.png"))

bxy.addImage("tree", readImage("assets/plants/tree.png"))
bxy.addImage("ded_tree", readImage("assets/plants/dead_tree.png"))

var frame: int

for num in 1..100:
  randomize()
  gorbs.add(Gorb(
    id: get_new_id(),
    alive: true,
    is_baby: false,
    position: vec2(
      rand(-1000..1000).toFloat(),
      rand(-1000..1000).toFloat()
    ),
    state: GorbState.NONE,
    energy: rand(40..180).toFloat(),
    speed: rand(1..60) / 10,
    view_range: rand(100..200)
  ))

for fruit_num in 1..500:
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

proc update() =
  if not paused:

    # Day / Night cycle
    time += 1
    if time >= 2400:
      if is_day:
        is_day = false
      else:
        is_day = true
      time = 0

    # process gorbs
    var gorb_count = 0
    for gorb in gorbs:
      gorbs[gorb_count] = gorb.process_ai()
      gorbs[gorb_count] = gorb.detect_eating()
      gorbs[gorb_count] = gorb.try_reproduce()
      gorb_count += 1
    
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
      var a_gorb_lives = false
      for gorb in gorbs:
        if gorb.alive:
          a_gorb_lives = true
          break
      if not a_gorb_lives:
        they_are_alive = false
        echo "they are all dead :)"

  # Camera controller
  if window.buttonDown[Button.KeyUp]:
    camera_offset[1] += CAMERA_SPEED
  if window.buttonDown[Button.KeyDown]:
    camera_offset[1] -= CAMERA_SPEED
  if window.buttonDown[Button.KeyLeft]:
    camera_offset[0] += CAMERA_SPEED
  if window.buttonDown[Button.KeyRight]:
    camera_offset[0] -= CAMERA_SPEED
  
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
    else:
      echo "ERROR: command not recognised"

# Called when it is time to draw a new frame.
proc draw() =
  #let center = window.size.vec2 / 2

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
            bxy.drawImage("smol_gorb", gorb.position + camera_offset, 0, gorb.colour_tint)
          else:
            bxy.drawImage("gorb", gorb.position + camera_offset, 0, gorb.colour_tint)
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

  # End frame
  bxy.endFrame()
  window.swapBuffers()
  inc frame

while not window.closeRequested:
  update()
  draw()
  pollEvents()