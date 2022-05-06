import std/random
import boxy, opengl, windy
import gorb, fruit

let windowSize = ivec2(1000, 600)
let window = newWindow("Genetic gorbs", windowSize)
makeContextCurrent(window)
loadExtensions()
let bxy = newBoxy()

var paused = false

var camera_offset = vec2(0, 0)
let CAMERA_SPEED: float = 5

var fruit_spawn_timer = 30
var they_are_alive = true

var gorbs = @[
  Gorb(
    alive: true,
    position: window.size.vec2 / 2,
    state: GorbState.NONE,
    energy: 100.0,
    speed: 3.0
  )
]

var fruits = @[
  Fruit(
    position: window.size.vec2 / 2
  )
]

# Load the images.
bxy.addImage("background", readImage("assets/background.png"))
bxy.addImage("gorb", readImage("assets/gorb.png"))
bxy.addImage("ded_gorb", readImage("assets/ded_gorb_sad.png"))
bxy.addImage("fruit", readImage("assets/fruit.png"))

var frame: int

for num in 1..25:
  randomize()
  gorbs.add(Gorb(
    alive: true,
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

    # Move gorbs
    var gorb_count = 0
    for gorb in gorbs:
      gorbs[gorb_count] = gorb.process_ai(fruits)
      (gorbs[gorb_count], fruits) = gorb.detect_eating(fruits)
      #(gorbs[gorb_count], gorbs) = gorb.reproduce(gorbs)
      gorb_count += 1
  
    # Fruit spawning
    if fruit_spawn_timer <= 0:
      randomize()
      fruits.add(Fruit(
        position: vec2(
          rand(-100..1000).toFloat(), #rand(10..toInt(window.size.vec2[0] - 10)).toFloat(),
          rand(-100..1000).toFloat() #rand(10..toInt(window.size.vec2[1] - 10)).toFloat()
        )
      ))
      fruit_spawn_timer = 30
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
  
  # Debug tools
  if window.buttonPressed[Button.KeyO]:
    var living_gorbs = 0
    for gorb in gorbs:
      if gorb.alive:
        living_gorbs += 1
    echo "There are ", living_gorbs, " gorbs still alive"
  if window.buttonPressed[Button.KeyP]:
    if paused:
      paused = false
      echo "unpaused"
    else:
      paused = true
      echo "paused"

# Called when it is time to draw a new frame.
proc draw() =
  let center = window.size.vec2 / 2

  # Start rendering new frame
  bxy.beginFrame(windowSize)

  bxy.drawImage("background", center, 0)

  for fruit in fruits:
    bxy.drawImage("fruit", fruit.position + camera_offset, 0)

  for gorb in gorbs:
    if gorb.alive:
      bxy.drawImage("gorb", gorb.position + camera_offset, 0)
    else:
      bxy.drawImage("ded_gorb", gorb.position + camera_offset, 0)

  # End frame
  bxy.endFrame()
  window.swapBuffers()
  inc frame

while not window.closeRequested:
  update()
  draw()
  pollEvents()