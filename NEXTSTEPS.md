NEXTSTEPS
---------

- Perhaps there are many different kinds of goals... Described
  by game states and phenomena rather than scores
  - could also use all that empty space on the side to write little
    poems that are triggered environmentally

- When you play for long enough, you start to build a little
  cave.
  - the terrain on the map really starts to obstruct your movement,
    and you have to be constantly digging to stay alive
    - have dynamic light pour in from the top of the screen
      - maybe rather than the dark grey blocks that are left
        over, the background tiles are produced by light, and they
        flood into the cave through its openings...
      - or the dynamic lighting is a triangle of light augments the
        brightness of energy fields and the background
      - perhaps there are some things that grow best in shade...

- As you play, the screen fills up with the darkest grey squares,
  left over from disappeared blocks.
  - one thought I had was that a function of this height could be
    the score: maybe the average height of the topmost background tile
    - could be the score multiplier
    - I wanted to blocks to fade over time, so maybe the multiplier
      fades too...

- something needs to trigger the transition
  - It would be very hard to clear the screen on a grey block break,
    but also it could be done too early so that probably isn't a
    good trigger
  - the trigger should be something a player is more likely to do
    the longer they play a single session

- Maybe make the grey blocks easier to destroy, but they only
  send motes when they are ripe.
  - when they are ripe, they rattle a little
  - The sending is our most ancient ritual.
  - maybe the title of the game is "A Ritual of Sending"

- The game should record the breaking of simple coloured blocks somehow.
  This feels like the most intuitive device: the grey blocks obstruct
  your ability to create nice chains.
  - the score might not necessarily be linear or natural,
    it is meant to imply that breaking coloured blocks is the
    primary activity, but on closer inspection this score
    does not seem to make sense... so there must be something else.
    - use alien symbols, group action etc. of the three colours
    - maybe the symbols determine what happens when the grey blocks
      are shattered? They can be programmed

- maybe life gets better after we send a block, but in ways that
  might be seen as a coincidence?
  - I was thinking, after sending a particular kind of block,
    the next few blocks would come in a pattern? Maybe use
    AI to either choose the squares folks need most for the next
    little while?
  - maybe the mote hangs out on the screen for a while, before taking off?

- I'm playing and I feel like I want to clear blocks. Creating grey blocks
  feels like a mistake, because it obstructs chains. It is also the habitual
  or easy thing to do.

## FEATURES

#### CAMERA & TITLE
[x] implement a camera
[x] Make the camera appear to be going down smoothly
[x] Make a title screen and game over (just like in GSS)
[x] ESC to quit to menu, and to quit game
[x] when the game ends, the camera should roll back up across
    the board
[x] when we start, the screen is white and the board fades in
[x] when the background has faded all the way to black, the foreground
    starts to fade to black with every keypress, pulling
    a "these robotic hearts of mine"
    - at some point the game should wipe the save
[x] in the start and end states, we should hear the whistling wind
[x] make hardening more clearly negative
    x perhaps if they harden a block before breaking a block, just
      fade back to white and start over
      x a little heavy handed...
      x an aborting state, with a fade in of the curtain and then just
        transition to start again?
      x then maybe add a flash of white whenever the player hardens,
        to remind them later in the game
[x] starting from a loaded save should start you in title screen,
     fade into it and press space to play

[ ] find a longer wind sound effect
    - the fade out should be from a strong wind
    - the fade in should build from nothing
[ ] add an undertale style gong to the title
[ ] choose a more angry sound effect for hardening

[ ] change the way the game handles a loss during the winddown
    - currently if you lose while the screen is fading, you just have to watch
      it fade to black... probably better if it just ends like a lose state?
    - maybe just having the wind fade in will help people understand...?

#### WILFIX

[ ] the "pop" sound for breaking should precede the "shatter" sound
[ ] fullscreen doesn't work on my laptop OSX

#### LOVELY
[x] make it so that colored blocks can get "pre-damaged" by blocks
    exploding nearby
[x] grey blocks should be made out of tiny triangles
[x] Reimplement shadows
[x] implement "resume" so that the ESC does not
    clear the game.
    - as part of this, the camera must roll back down to the current position
[x] implement save/load so that progress is not lost on restart
[x] remove the title, menu, etc...
[x] maybe the background gets darker the deeper we go?
[x] Sound effects and music

#### NICE TO HAVE

[ ] it should be _almost_ "any key" to start
[ ] make the camera movement sigmoidal
    - should it be constant time to complete?
    - make it physicsy? ie it "falls" down
      and "pushes" up, as though climbing by
      an engine?
[ ] vary the alpha of the shadow tiles randomly? Or maybe based on
    neighbour sample? So that there is something to look at in the
    background
    - or have them fade out completely...
[x] when we quit the game, transition to a "saving" state where a black screen with "saving" is drawn for 2 seconds
    - an actual state in the state machine that takes a fixed time,
      like one second
[ ] the motes should shine through damaged block hearts
[ ] when coloured blocks break, the explosion should chain out
    from the block that tripped it
[ ] Adjust speed/game feel
[ ] some parallaxing background to make it more clear that
    we are moving down
[ ] instead of having the camera move when a new layer is reached,
    have it move after 'n' new layers are reached or after some delay
    to give it a more organic feel?
[ ] the little sprites need a sound effect
[ ] consider removing the "damage unbroken blocks" rule
    if it is making things to easy (playtest)

## BUGS

[x] the game collects input for arrow keys on the title screen
    - this is a deeper problem: we are mixing inputpressed and keypressed
      and the FSM only cares about keypressed
    - so either add inputpressed to the FSM or make everything use keypressed
[x] after the game shifts, the next_block appears off screen
    these need to be flushed before the next state
[x] the next block and current block should be saved as well
[x] losing doesn't work anymore
    [x] make all the coloured blocks animate to grey
    [x] reset saved state
    [x] reset the game when the player restarts
[x] the game seemed to get stuck on the title screen
[x] apparently the game loop updates in the wind state despite everything?
[x] the next_block comes on in the wrong place after scroll/load
[x] the camera seems to rewind into a tiny negative value, which results in weirdness
[x] the camera never actually settles back to zero, it just approaches zero
    - add a snap-to-zero for some sub pixel EPSILON?
[x] when a fully split live block is damaged, the block heart disappears
    and then weird behaviour ensues...
[x] when we decode game.board the rows of "false" become rows of "nil"
[x] finally using "block.color == block.color.grey" has bit me
    I need to change any object identity comparisons to boolean comparisons
[x] mutable state is in game.state but it should be loaded into a local
    wherever it will be used frequently, to avoid all this "game.state.camera.x" too many dots
[x] the game pauses to save/load; ideally this is done in a thread, but
    barring that just save/load whenever camera is not moving
