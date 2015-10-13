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
[ ] ESC to quit to menu, and to quit game
[ ] Make the camera appear to be going down smoothly
    - implement a camera
[ ] Make a title screen and game over (just like in GSS)
[ ] when the game ends, the camera should roll back up across
    the board
    - so, fade in title screen while the camera rolls back up
      to a blank screen?

#### LOVELY
[ ] Reimplement shadows
[ ] grey blocks should be made out of tiny triangles, so that the mote
    can shine through. Only some blocks contain motes.
[ ] Add some kind of variation to mark the passage downward
    - not necessarily a depth marker
    - no need for a high score (it will be up on itch/gamejolt)
[ ] Sound effects and music
    - music should become more panic the more
    full rows there are above "ground level"
    stack higher?

#### NICE TO HAVE
[ ] Adjust speed/game feel
[ ] Maybe have blocks of different hardness?
[ ] something with the motes...
    - not necessarily, it may be OK to just leave them

[ ] when coloured blocks break, the explosion should chain out
    from the block that tripped it

## BUGS

[ ] sometimes the block borders are rendered round, for no apparent reason
    and randomly...

[ ] sometimes blocks don't break after a chain

