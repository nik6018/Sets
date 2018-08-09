# Sets

Sets is an single player card matching game. Here instead of the diamond,squiggle and oval other simpler shapes like circle , square and triangle are used to represent the symbols.

UIKitDynamics and Core Graphics frameworks are heavily used to mimic the real world behaviour of the cards.

Most of the App has custom UI and layout mechanism to provide a delighful UX.

The App is a universal app which supports all screens sizes from iPhone to iPad.

## GamePlay

The Game has 81 cards in the deck and 12 cards are delt to begin with, the cards have 4 distinct attributes (shape, pattern,
color and shape count) to make each of them unique in the Deck.
<p align="left">
  <img src="images/home.png" width="250" title="Home">
  <img src="images/landscape.png" height="300" width="600" title="Landscape">
</p>

3 matching cards make a Set, once a Set is found they are moved to the discard pile and new cards are delt, if you can't find any match then you can choose to deal 3 more cards which will give you a better chance to find a match(Set).

Only a maximun of 24 cards can be present in the playing area, so you have to find a match before you draw cards from the deck.

### Rules for finding a Set

A Set consists of three cards satisfying all of these conditions:

1. The cards must have the same color or different color
2. The cards must have the same shape or different shape
3. The cards must have the same pattern or different pattern
4. The cards must have the same shape count or different same shape count


The game ends when no Sets can be found in the playing cards.
