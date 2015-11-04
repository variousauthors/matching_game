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

#### LOVELY
[x] make it so that colored blocks can get "pre-damaged" by blocks
    exploding nearby
[x] grey blocks should be made out of tiny triangles
[x] Reimplement shadows
[x] implement "resume" so that the ESC does not
    clear the game.
    - as part of this, the camera must roll back down to the current position
[ ] implement save/load so that progress is not lost on restart
[ ] make the camera movement sigmoidal
    - should it be constant time to complete?
[ ] remove the title, leaving just "press space"
[ ] Add some kind of variation to mark the passage downward
    - make a quick affirmation generator, and show affirmations
      as the player descends
    - should they "fade in", triggered by some different action?
    - maybe add an angelic choir sound effect?
[ ] Sound effects and music
    - music should become more panic the more
    full rows there are above "ground level"
    stack higher?

#### NICE TO HAVE

[ ] the motes should shine through damages block hearts
[ ] when coloured blocks break, the explosion should chain out
    from the block that tripped it
[ ] Adjust speed/game feel
[ ] maybe the background gets darker the deeper we go?
[ ] some parallaxing background to make it more clear that
    we are moving down
[ ] instead of having the camera move when a new layer is reached,
    have it move after 'n' new layers are reached or after some delay
    to give it a more organic feel?

## BUGS

[x] finally using "block.color == block.color.grey" has bit me
    I need to change any object identity comparisons to boolean comparisons
[ ] when we decode game.board the rows of "false" become rows of "nil"
[ ] the camera seems to rewind into a tiny negative value, which results in weirdness
[ ] the camera never actually settles back to zero, it just approaches zero
    - add a snap-to-zero for some sub pixel EPSILON?
[ ] the game collects input for arrow keys on the title screen
    these need to be flushed before the next state
[ ] the game seemed to get stuck on the title screen
[x] when a fully split live block is damaged, the block heart disappears
    and then weird behaviour ensues...
[ ] sometimes the block borders are rendered round, for no apparent reason
    and randomly...

[ ] sometimes blocks don't break after a chain

