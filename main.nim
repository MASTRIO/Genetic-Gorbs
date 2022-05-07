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

let timer_max = 0
var fruit_spawn_timer = timer_max
var they_are_alive = true

# Load the images.
bxy.addImage("background", readImage("assets/background/background.png"))

bxy.addImage("gorb", readImage("assets/gorb/gorb.png"))
bxy.addImage("smol_gorb", readImage("assets/baby/baby_gorb.png"))

bxy.addImage("ded_gorb", readImage("assets/gorb/ded_gorb_sad.png"))
bxy.addImage("ded_smol_gorb", readImage("assets/baby/ded_baby_pog.png"))

bxy.addImage("gorb_gonna_die", readImage("assets/gorb/gorb_dying.png"))

bxy.addImage("gorb_might_die", readImage("assets/gorb/gorb_dying_but_less.png"))

bxy.addImage("fruit", readImage("assets/fruit/fruit.png"))

bxy.addImage("tree", readImage("assets/plants/tree.png"))

var frame: int

for num in 1..50:
  randomize()
  gorbs.add(Gorb(
    id: get_new_id(),
    alive: true,
    is_baby: false,
    position: vec2(
      rand(0..800).toFloat(),
      rand(0..500).toFloat()
    ),
    state: GorbState.NONE,
    energy: rand(40..180).toFloat(),
    speed: rand(1..60) / 10,
    view_range: rand(200..350)
  ))

for fruit_num in 1..200:
  randomize()
  fruits.add(Fruit(
    position: vec2(
      rand(-1000..1500).toFloat(), #rand(10..toInt(window.size.vec2[0] - 10)).toFloat(),
      rand(-1000..1500).toFloat() #rand(10..toInt(window.size.vec2[1] - 10)).toFloat()
    )
  ))

proc update() =
  if not paused:

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
        echo "added gorb from queue position ", queue_counter
        echo gorb_queue
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
          rand(-2000..2000).toFloat(), #rand(10..toInt(window.size.vec2[0] - 10)).toFloat(),
          rand(-2000..2000).toFloat() #rand(10..toInt(window.size.vec2[1] - 10)).toFloat()
        )
      ))
      fruit_spawn_timer = timer_max
    else:
      fruit_spawn_timer -= 1
  
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
      else:
        echo "ERROR: invalid argument '", command[1], "'"
    else:
      echo "ERROR: command not recognised"

# Called when it is time to draw a new frame.
proc draw() =
  let center = window.size.vec2 / 2

  # Start rendering new frame
  bxy.beginFrame(windowSize)

  bxy.drawImage("background", center, 0)

  for fruit in fruits:
    if on_screen(fruit.position, window.size.vec2, camera_offset):
      bxy.drawImage("fruit", fruit.position + camera_offset, 0)

  for gorb in gorbs:
    if on_screen(gorb.position, window.size.vec2, camera_offset):
      if gorb.alive:
        if gorb.is_baby:
          bxy.drawImage("smol_gorb", gorb.position + camera_offset, 0)
        else:
          if gorb.energy < 4:
            bxy.drawImage("gorb_gonna_die", gorb.position + camera_offset, -0.6)
          elif gorb.energy < 2:
            bxy.drawImage("gorb_gonna_die", gorb.position + camera_offset, -0.54)
          elif gorb.energy < 3:
            bxy.drawImage("gorb_gonna_die", gorb.position + camera_offset, -0.48)
          elif gorb.energy < 4:
            bxy.drawImage("gorb_gonna_die", gorb.position + camera_offset, -0.42)
          elif gorb.energy < 5:
            bxy.drawImage("gorb_gonna_die", gorb.position + camera_offset, -0.4)
          elif gorb.energy < 10:
            bxy.drawImage("gorb_gonna_die", gorb.position + camera_offset, -0.3)
          elif gorb.energy < 20:
            bxy.drawImage("gorb_gonna_die", gorb.position + camera_offset, -0.2)
          elif gorb.energy < 30:
            bxy.drawImage("gorb_gonna_die", gorb.position + camera_offset, -0.1)
          elif gorb.energy < 50:
            bxy.drawImage("gorb_might_die", gorb.position + camera_offset, 0)
          else:
            bxy.drawImage("gorb", gorb.position + camera_offset, 0)
      else:
        if gorb.is_baby:
          bxy.drawImage("ded_smol_gorb", gorb.position + camera_offset, 0)
        else:
          bxy.drawImage("ded_gorb", gorb.position + camera_offset, 0)

  for tree in trees:
    if on_screen(tree.position, window.size.vec2, camera_offset):
      bxy.drawImage("tree", tree.position + camera_offset, 0)

  # End frame
  bxy.endFrame()
  window.swapBuffers()
  inc frame

while not window.closeRequested:
  update()
  draw()
  pollEvents()