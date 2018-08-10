# Sets

Sets is an single player card matching game. Here instead of the diamond,squiggle and oval simpler shapes like circle , square and triangle are used to represent the symbols.

UIKitDynamics and Core Graphics frameworks are heavily used to mimic the real world behaviour of the cards.

Most of the App has custom UI and layout mechanism to provide a delighful UX.

The App supports all screens sizes from iPhone to iPad.

## GamePlay

The Game has 81 cards in the deck and 12 cards are delt to begin with, the cards have 4 distinct attributes (shape, pattern,
color and shape count) to make each of them unique in the Deck.
<p align="left">
  <img src="images/home.png" width="250" title="Home">
  <img src="images/landscape.png" height="300" width="600" title="Landscape">
</p>

3 matching cards makes a Set, once a Set is found they are moved to the discard pile and new cards are delt, if you can't find any match then you can choose to deal 3 more cards which will give you a better chance to find a match(Set).

Only a maximun of 24 cards can be present in the playing area, so you have to find a match before you draw cards from the deck.

### Rules for finding a Set

A Set consists of three cards satisfying all of these conditions:

1. The cards must have the same color or different color
2. The cards must have the same shape or different shape
3. The cards must have the same pattern or different pattern
4. The cards must have the same shape count or different same shape count


The game ends when no Sets can be found in the playing cards.

## Under the Hood Details

### Core Graphics

The App heavly depends on Core Graphics for the Custom drawing.

Depending on the number of shapes a card is divided into equal number of sections, then the actual RECT for the shape is calculated using a ratio to the cards width in potrait and using the height in landscape.

Shapes like circle, triangle and square are very straightforward to draw using <b>UIBezierPath</b> in the defined RECT.

The Stripped pattern present an interesting challenge while drawing as it's very inefficient to draw the pattern  only in
defined RECT for the shape.

While drawing the stripped pattern <code>UIGraphicsGetCurrentContext</code> is used to save the state of existing drawing operation, after that the actual RECT in which the pattern is to be drawn is set the property <code>addClip</code> to clip any drawing outside the path that defines the shape.
  
 Then the stripped pattern is drawn in two parts 
 1. Start from the midpoint of the card and keep drawing lines to the max height of the card and continue towards the origin.
 2. Again start from the same position as above but this time the lines are drawn towards the MAX value of X.
 
 Since the RECT had <code>addClip</code> property set, the stripped pattern is only visible in the shape RECT.
 
 Due to the above property all further drawing will be clipped thus we restore the previous <code>UIGraphicsGetCurrentContext</code> state which will restore the properties and allow further drawing.
 
 ### UIKitDynamics
 
 UIKitDynamics is used to apply physics based animation to the cards.
 
 The following behaviours are used to apply a 2D animations to the cards
 
 1. <b>UIPushBehaviour</b>
 
 Once the cards are matched they are pushed at a random angle using the above behaviour from the original position.
 
 2. <b>UICollisionBehaviour</b>
 
 When the pushed cards come in contact with each other they collide with each other using the above behaviour and bounce off each other.
 
 3. <b>UISnapBehaviour</b>
 
 After colliding with each other the cards float around the content view for some time and after that they are snapped to the discard pile.
 
 4. <b>UIGravityBehaviour</b>
 
 If the game is finished or you wish to start a new game, pressing the restart button causes the cards to experience gravity and fall down from their original position
 
 5. <b>UIDynamicItemBehaviour</b>
 
 All the cards in the game act as an UIDynamicItem to all the above behaviours, but items themselves can have behaviours applied to them using.
 
 The cards have elasticity for gaining energy when they collide with each other so they don't stop moving in the content area.
 
 <hr>
 
 #### Videos
 Since the animations are all dynamic in nature I have made videos which are present in the images/ folder which show all the UIKitDynamic Animations.
