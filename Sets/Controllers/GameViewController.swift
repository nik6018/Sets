//
//  GameViewController.swift
//  Sets
//
//  Created by Nikhil Muskur on 28/04/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

/*
 TODO: //
 1) Adjust the Border stroke if frame is recalculated #done
 2) Add a gradient to the background #done
 3) After adding certain number of cards alert the user that he has to find a Set to deal more cards #done
 4) Change the Selection UI Maybe change the background of the card  #tried #notlookinggood #skipping
 5) Adjust the shape rect only if we have 3 shapes otherwise it's not required #done
 6) Reposition the Cards left in Deck Label to somewhere else, so that it looks nice.
 7) Generate Score if possible
 8) Show an congratulation message after completing the game
 9) When few cards remain check if a set is possible otherwise end the game(Still not tested)
 10) Show a different screen for scores and implement themes if possible.
 11) Add a algorithm for hints, first make it user activated(passive) and then make it dynamic(active)
 ------------------------------------------------------------------------------------------------------
 Possible Steps:
 +++++++++++++++
 1)card1 - base card
 2)card2 then try to match with rest of the cards (skip 1 & 2)
 1)card1 - base card
 2)card3 then try to match with rest of the cards (skip 1 & 3)
 The skip 3 cards from the base card
 1)card4 - base card
 2)card5 then try to match with rest of the cards (skip 4 & 5)
 1)card4 - base card
 2)card6 then try to match with rest of the cards (skip 4 & 6)
 ------------------------------------------------------------------------------------------------------
 12) Make a custom View for alerts if possible
 13) Adjust the dynamic card layout even further #done
 14) Add an extension for UIColor initialization #done
 15) Try to increase the width of the contentView if it looks good. #tried #notlookinggood
 16) For Outline shapes increase stroke width or use a more solid color #done
 17) Restore the game state if force quit occurs
 18) Assign all corrent access modifiers
 19) Don't reduce height and width down the shapeRect for landscape #done
 20) Instead of reducing the width and height for TODO: 5 & 19 use CGAffineTransform if that makes sense
 21) Create a public API for any VC to initialize a new Game(can use this for Restart button) #done #canImprove
 22) Improve the Architecture #done #canImprove
 23) Try to separate view logic into GridView.swift file (can be clubed with TODO: 22)
 24) Selection border looks too thin in landscape #done
 *) Solve the animation bug when scaling and 3 cards are matched #done
 25) Animate cards while dealing them , also create a remaining card deck and show the animate dealing from that #done
 26) If 3 cards are selected then scale them and move to center and check whether they match or not #done
 26.1) Make the background Black so will need to raise the zPosition val for card and bacgrnd #done
 27) If cards matched after a timer of 2 seconds animate the cards into a deck with Matched cards #done
 28) Replace the basic shapes with diamond, squiggles and rounded rects
 29) Add animation while switching to landscape #done #again_broken
 30) When 3 cards are matched and user presses deal button or a
     new card replace the existing card and not add new cards #done
 31) Card Attributes 3 Enums don't require and raw value as they are never used #notDone, #required
 32) Deal me 3 cards animation breaks sometime find the edge case #not found #keeptrying
 33) Stripe pattern last line issue in potrait mode
 34) Implement a Gravity Animation Behaviour for restart button
    (i.e  All cards should fall down one by one and then restart of the game should occur)
 */

import UIKit

class GameViewController: UIViewController, UIDynamicAnimatorDelegate {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var dealMe3MoreCardsButton: UIButton!
    @IBOutlet private weak var restartButton: UIButton!
    @IBOutlet private weak var hintButton: UIButton!
    @IBOutlet weak var deckStatus: UILabel! {
        didSet {
            self.title = "Cards in Deck: 81"
        }
    }
    @IBOutlet weak var sV: UIStackView!
    @IBOutlet weak var pileButton: UIButton! {
        didSet {
            pileButton.setTitle("(0) Sets", for: .normal)
        }
    }
    
    @IBAction private func dealMe3MoreCardsButtonPressed(_ sender: UIButton) {
        handleDealMe3CardsEvent()
    }
    
    @IBAction private func restartGame(_ sender: UIButton) {
        // Will remove all the current cards
        self.contentView.subviews.forEach { $0.removeFromSuperview() }
        // Reinitialize the deck as well as the contentView
        initializeTheDeck()
        setUpCards()
        setCount = 0
    }
    
    @IBAction private func showHints(_ sender: UIButton) {
        //check if any selected cards are present or not, if yes then alert the user
        
        //get all the identifiers of the currently displayed cards and then pass to model func
        let cardIdentifiersInPlay = cardsInPlay.reduce(into: []) { x,y in x.append(y.identifier) }
        //call something on the model to show hints
        let matchedCardIdentifiersForHints = gameDeck.findHints(fromCardsWithIdentier: cardIdentifiersInPlay)
        //and then update the view based on the result
    }
    
    @IBAction private func swipeDown(_ sender: UISwipeGestureRecognizer) {
        print("Swipe Down Gesture Recognized")
        handleDealMe3CardsEvent()
    }
    
    @objc private func cardTap(tap: UITapGestureRecognizer) {
        
        if let tapView = tap.view as? SetView, cardsInPlay.contains(tapView) {
            /*
            UIView.transition(with: tapView,
                  duration: 1.0,
                  options: [.transitionFlipFromLeft, .curveEaseInOut],
                  animations: {
                    tapView.faceUp = false
                    
                }) { (isFinished) in
                        if isFinished {
                            UIView.transition(with: tapView,
                                  duration: 0.6,
                                  options: [.transitionFlipFromLeft, .curveEaseIn],
                                  animations: { tapView.faceUp = true })
                        }
                    }
            */
            let isSelected = gameDeck.selectedCards.contains(tapView.identifier)
            let isMatched = gameDeck.matchedCards.contains(tapView.identifier)
            
            if isSelected && gameDeck.selectedCards.count < 3 {
                gameDeck.selectedCards.remove(at: gameDeck.selectedCards.index(of: tapView.identifier)!)
            } else if !isMatched {
                gameDeck.pickCard(cardIdentier: tapView.identifier)
            }
            
            refreshView()
        }
        
    }
    
    private var setView: SetView!
    private(set) var setCount: Int = 0 {
        didSet {
            pileButton.setTitle("(\(setCount)) Sets", for: .normal)
        }
    }
    private var grid: Grid!
    private var gameDeck: Deck!
    private(set) var cardsInPlay: [SetView]!
    private var gridRowCount: Int!
    private var gridColumnCount: Int!
    private var cButtonYPoint: CGRect!
    private var flyAwayCards = [SetView]()
    private var viewSize: CGRect?
    
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    private lazy var cardBehaviour = CardBehaviour(with: animator)

    
    var isDealCardPossible: Bool {
        return gameDeck.cards.count > 0
    }
    var isGameInIntialState: Bool {
        return cardsInPlay.count == 0
    }
    private var setColor: UIColor {
        return UIColor.initializeTheColor(_red: 0, _green: 120, _blue:0)
    }
    private var nonSetColor: UIColor {
        return UIColor.initializeTheColor(_red: 125, _green: 0, _blue: 0)
    }
    private var cardsToAnimate = [SetView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup the Buttons
        dealMe3MoreCardsButton.layer.cornerRadius = 3.0
        restartButton.layer.cornerRadius = 3.0
        
        initializeTheDeck()
        
        animator.delegate = self

        print("The Frame of the Button is \(contentView.frame)")
    }
    
    // is called when all frame and bound for all sub views are set.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("IN VDLS")
        cButtonYPoint = sV.frame
        print("The Value of the Frame is : \(cButtonYPoint)")
        setUpCards()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // animate while the rotation animation is happening
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: self.view, animation: { _ in
          self.setUpCards()
        })
    }
    
    
    func initializeTheDeck() {
        gameDeck = Deck()
        cardsInPlay = [SetView]()
    }
    
    private func updateExistingGrid(_ completionBlock: @escaping () -> Void) {
        guard cardsInPlay.count > 0 else { completionBlock();return }
//        let animator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.5, animations: nil)
        
        let gridsToUpdate = cardsInPlay.count
        
        for gridIndex in 0..<gridsToUpdate {
            let cardView = cardsInPlay[gridIndex]
            let reAdjustAnimation = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.5){
                cardView.frame = self.grid[gridIndex]!.insetBy(dx: 5.0, dy: 5.0)
            }
            
            reAdjustAnimation.startAnimation()
            
            if gridIndex == gridsToUpdate - 1 {
                reAdjustAnimation.addCompletion { _ in
                    completionBlock()
                }
            }
            
            cardView.setNeedsDisplay()
            contentView.addSubview(cardView)
        }
    }
    
    private func replaceMatchedCards (){
        
        gameDeck.matchedCards.forEach { (identifier) in
            if let cardIndex = cardsInPlay.index(where: { $0.identifier == identifier}) {
                let card = cardsInPlay[cardIndex]
                cardsToAnimate.append(card)
            }
        }
        
        flyAwayAnimationForCard() {
            self.gameDeck.matchedCards.forEach { (identifier) in
                if let cardIndex = self.cardsInPlay.index(where: { $0.identifier == identifier}) {
                    var card = self.cardsInPlay[cardIndex]
                    self.deSelect(card)
                    
                    if let newCard = self.gameDeck.drawCard() {
                        card = self.updateCardAttribute(fromCard: newCard, toCard: card)
                        self.cardsToAnimate.append(card)
                    } else {
                        print("Unable to find the Matched card in CardsInPlay array.. something's wrong")
                    }
                }
            }
            
            self.animateDealCards()
            
            //check the Deal Me 3 cards Button status (Have to again call them here due to closure delay)
            self.updateCardsInDeckStatus()
            self.toggleDealButton()
            
            self.gameDeck.matchedCards.removeAll()
        }
        
//        cardsToAnimate = _cardsToAnimate
//        animateDealCards()
        
        
       /*
        gameDeck.matchedCards.forEach { (identifier) in
            if let cardIndex = cardsInPlay.index(where: { $0.identifier == identifier}) {
                let card = cardsInPlay[cardIndex]
                
                if let newCard = gameDeck.drawCard() {
                    //flyAwayAnimation(card, newCard, cardIndex)
//                    card = updateCardAttribute(fromCard: newCard, toCard: card)
//                    gravityBehavior.addItem(card)
//                    deSelect(card)
//                    card.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//                    UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.8){
//                        card.transform = .identity
//                    }.startAnimation()
                    
                    // IMP Step otherwise card will not be visible
//                    cardsInPlay[cardIndex] = card
//                    cardsInPlay[cardIndex].setNeedsDisplay()
//                    flyAwayAnimation(card,nil, .show)
                }
            } else {
                print("Unable to find the Matched card in CardsInPlay array.. something's wrong")
            }
        }*/
        
        // empty the matched cards deck once the card are replaced.
    }
    
    private func refreshView() {
        guard cardsInPlay.count > 0 else { return }
        
        var cardsToRemove = [SetView]()
        
        for cardindex in cardsInPlay.indices {
            let card = cardsInPlay[cardindex]
            
            if gameDeck.selectedCards.contains(card.identifier) {
                var borderColor: UIColor = .black
                let identifier = card.identifier
                if gameDeck.selectedCards.count == 3 {
                    borderColor = gameDeck.matchedCards.contains(identifier) ? setColor : nonSetColor
                }
                
                card.drawRoundedBorder(withColor: borderColor)
            } else {
                if gameDeck.matchedCards.contains(card.identifier) {
                    // remove from matchedCards, cardsInPlay
//                    if let identifierIndex = gameDeck.matchedCards.index(of: card.identifier) {
//                        gameDeck.matchedCards.remove(at: identifierIndex)
                        cardsToRemove.append(card)
//                    } else {
//                        print("Cannot find the matched card in the gamedeck might be a bug")
//                    }
                }
                
                deSelect(card)
            }
        }
        
        if cardsToRemove.count > 0 {
            replaceMatchedCards()
        }
        
        //check the Deal Me 3 cards Button status
        updateCardsInDeckStatus()
        toggleDealButton()
    }
    
    
    private func setUpCards(withAddtionalCards shouldAddNewCard: Bool = false) {
    
        var columnCount = 0
        var rowCount = 0
        var expectedCardsInPlay = 0
        
        
        func calculateGrid(_ addCards: Bool) {
            
            // Change the starting Grid if the game is played on an iPad
            if isGameInIntialState {
                if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
                    rowCount = 7
                    columnCount = 3
                } else {
                    rowCount = 4
                    columnCount = 3
                }
                expectedCardsInPlay = rowCount * columnCount
            } else {
                expectedCardsInPlay = addCards ? cardsInPlay.count + 3 : cardsInPlay.count
                
                if expectedCardsInPlay > 15 {
                    columnCount = 4
                    let remainder = expectedCardsInPlay % columnCount
                    
                    switch remainder {
                    case 1...4:
                        rowCount = 1
                    default:
                        rowCount = 0
                    }
                    
                    rowCount +=  Int(expectedCardsInPlay / columnCount)
                } else {
                    columnCount = 3
                    rowCount = expectedCardsInPlay / 3
                }
            }
            
            
            grid = Grid(layout: Grid.Layout.dimensions(rowCount: rowCount, columnCount: columnCount), frame: contentView.bounds)
            
            // add new cards to the view after adjusting the current grid
            updateExistingGrid() { addCardsToView() }
        }
        
        
        
        calculateGrid(shouldAddNewCard)
        
        func addCardsToView() {
            let startPos = cardsInPlay.count
            let endPos = expectedCardsInPlay
            
            
            if expectedCardsInPlay > cardsInPlay.count {
                for index in startPos..<endPos {
                    setView = SetView(frame: grid[index]!.insetBy(dx: 5.0, dy: 5.0))
                    setView.backgroundColor = .clear
                    if let newCard = gameDeck.drawCard() {
//                        let animatedView = setView ?? UIView()
                        
                        setView = updateCardAttribute(fromCard: newCard, toCard: setView)
                        setView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTap)))
//                        let ogCardFrame = animatedView.frame
                    
                        
                       
                        cardsToAnimate.append(setView)
                        //self.contentView.addSubview(setView)
                        cardsInPlay.append(setView)
                    }
                }
            }
            
            //animate the dealing of the cards
            animateDealCards()
            
            // since the grid has changed adjust any selected cards border
            updateSelectedCardBorders()
        }
        
        refreshView()
    }
    
    private func animateDealCards(withDelay delay: TimeInterval = 0.0) {
        guard cardsToAnimate.count > 0 else { print("IN ELSE");return }
        
        print("Cards Left in deck before removing: \(self.cardsToAnimate.count)")
        let sV = cardsToAnimate.removeFirst()
        print("Cards Left in deck after removing: \(self.cardsToAnimate.count)")
        let ogFrame = sV.frame
        print("The Value of the Card is : \(sV.alpha)")
        
        self.contentView.addSubview(sV)
        
        sV.frame = CGRect(x: ogFrame.minX ,
                               y: contentView.frame.maxY,
                               width: ogFrame.size.width,
                               height: ogFrame.size.height)
        
        //gravityBehavior.addItem(setView)
        
        let dealAnimation = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.8) {
            sV.alpha = 1
            sV.frame = ogFrame
        }
        
        dealAnimation.startAnimation(afterDelay: delay)
        
        dealAnimation.addCompletion({ _ in
            print("In the Completion block")
            self.animateDealCards()
        })
    }
    
    func flyAwayAnimationForCard(_ completionBlock : @escaping () -> Void) {
        guard cardsToAnimate.count > 0 else { return }
        
        var cardsToFly = [SetView]()
        
        //create our new fly animation cards from the ogframe
        cardsToAnimate.forEach { (cardView) in
            let newCard = SetView(frame: cardView.frame)
            print("New Card Created for Flying")
            newCard.shapeCount = cardView.shapeCount
            newCard.shape = cardView.shape
            newCard.shapeColor = cardView.shapeColor
            newCard.fillType = cardView.fillType
            
            newCard.backgroundColor = UIColor.clear
            self.contentView.addSubview(newCard)
            flyAwayCards.append(newCard)
            cardsToFly.append(newCard)
        }
        
        print("The Count of Fly Away cards is : \(flyAwayCards.count)")
        
        cardsToFly.forEach { $0.layer.zPosition = 2;self.cardBehaviour.addItem($0) }
        
        Timer.scheduledTimer(withTimeInterval: 3.5, repeats: false) { (timer) in
            
            cardsToFly.forEach { self.cardBehaviour.removeItem($0) }
            
            cardsToFly.forEach({ (flyCard) in
                UIView.transition(
                    with: flyCard,
                    duration: 0.5,
                    options: [.transitionFlipFromLeft],
                    animations: {
                        flyCard.faceUp = false
                },
                    completion: { _ in
                        let pileButtonCenter = self.sV.subviews[1].center
                        let actualCenter = CGPoint(
                            x: self.sV.center.x + (pileButtonCenter.x - self.sV.bounds.midX),
                            y: self.sV.center.y)
                        let snap = UISnapBehavior(item: flyCard, snapTo: actualCenter)
                        snap.damping = 1.8
                        snap.action = {
                            self.pileButton.alpha = 0
                            flyCard.faceUp = true
                            flyCard.bounds = self.pileButton.bounds
                            flyCard.setNeedsDisplay()
                        }
                        
                        self.animator.addBehavior(snap)
                })
            })
        }
        
        let alphaAnimation = UIViewPropertyAnimator(duration: 0.5 , curve: .easeIn) {
            self.cardsToAnimate.forEach({ (card) in
                card.alpha = 0
            })
        }
        
        alphaAnimation.startAnimation()
        alphaAnimation.addCompletion { _ in
            self.cardsToAnimate.removeAll()
            print("Card to animate is now empty")
            completionBlock()
        }
        
//        cardsToAnimate.forEach { (cardView) in
//            let alphaAnimation = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut) {
//                cardView.alpha = 1
//            }
//            animations.append(alphaAnimation)
//            cardView.layer.zPosition = 2
//            cardBehaviour.addItem(cardView)
            
//            gravityBehavior.addItem(cardView)
//        }
        
        
        
        // so that completion block can add other cards to animate
//        cardsToAnimate.removeAll()
        
        // Set the completion block for the last animation only
//        if let lastAnimation = animations.last {
//            lastAnimation.addCompletion { _ in
//                completionBlock()
//            }
//        }
//
//        animations.forEach { $0.startAnimation() }
    }
    
    private func updateCardAttribute(fromCard newCard: Card, toCard card: SetView) -> SetView {
        
        card.identifier = newCard.identifier
        
        switch newCard.cardAttributes!.color {
        case .red: card.shapeColor = UIColor.red
        case .blue: card.shapeColor = UIColor.blue
        case .green: card.shapeColor = UIColor.initializeTheColor(_red: 0, _green: 95, _blue: 0)
            
        }
        
        switch newCard.cardAttributes!.shape {
        case .circle:   card.shape = "circle"
        case .square:   card.shape = "square"
        case .triangle: card.shape = "triangle"
        }
        
        switch newCard.cardAttributes!.pattern {
        case .filled:   card.fillType = "filled"
        case .outline:  card.fillType = "empty"
        case .stripped: card.fillType = "stripped"
        }
        
        card.shapeCount = newCard.cardAttributes!.shapeCount
        
        return card
    }
    
    func updateSelectedCardBorders() {
        gameDeck.selectedCards.forEach({ (selectedCardIdentifier) in
            if let cardIndex = cardsInPlay.index(where: { $0.identifier == selectedCardIdentifier}) {
                let card = cardsInPlay[cardIndex]
                card.drawRoundedBorder(withColor: UIColor.black)
            }
        })
    }
    
    func handleDealMe3CardsEvent() {
        // Alert User if he tries to draw too many cards
        if cardsInPlay.count >= 24 && gameDeck.matchedCards.count == 0 {
            alertUserAboutMaxCardDrawn()
        } else if gameDeck.matchedCards.count == 3 { // replace
            //will replace the currently matched cards, so need to refresh entire contentView
            refreshView()
        } else {
            // Will recalculate the GRID and refresh the view
            setUpCards(withAddtionalCards: true)
        }
    }
    
    private func toggleDealButton() {
         dealMe3MoreCardsButton.isEnabled = isDealCardPossible
    }
    
    private func deSelect(_ card: SetView) {
        card.layer.borderColor = UIColor.clear.cgColor
        card.layer.borderWidth = 0.0
    }
    
    private func updateCardsInDeckStatus() {
        deckStatus.text = "Deck: \(gameDeck.getCardsLeft())"
    }
}

private extension GameViewController {
    func alertUserAboutMaxCardDrawn() {
        
        let alert = UIAlertController(
                        title: "Warning",
                        message: "Maximun cards Drawn, find a Set to draw more cards",
                        preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}



enum CardState {
    case show
    case hide
}

extension GameViewController {
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        
        let snapBehaviours = animator.behaviors.filter { (behavior) -> Bool in
            if let _ = behavior as? UISnapBehavior {
                return true
            } else {
                return false
            }
        }

        // if the user clicks very quikly on the cards and they match
        if !animator.isRunning {
            print("Now Changing the Alpha")
            if snapBehaviours.count >= 3 {
                snapBehaviours.forEach { animator.removeBehavior($0) }
                self.setCount += (snapBehaviours.count / 3)
                if pileButton.alpha == 0 {
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.8,
                        delay: 0,
                        options: [.curveLinear, .beginFromCurrentState],
                        animations: {
                            self.pileButton.alpha = 1
                        }, completion: { _ in
                            //empty the flyAwayCards array otherwise something might break
                            if !self.flyAwayCards.isEmpty {
                                for _ in 0..<3 {
                                    let card = self.flyAwayCards.removeFirst()
                                    card.removeFromSuperview()
                                }
                            }
                            print("Method : \(#function) on line :\(#line) :  with FlyCard Cout \(self.flyAwayCards.count)")
                        }
                    )
                }
            }
        }
    }
}

/*
 func _setUpCards() {
 // clear all the SubViews
 self.contentView.subviews.forEach { $0.removeFromSuperview() }
 
 grid = Grid(layout: Grid.Layout.dimensions(rowCount: gridRowCount, columnCount: gridColumnCount), frame: contentView.bounds)
 
 for cardFrame in 0..<grid.cellCount {
 // Grid Frame can also be empty so add check for that condition
 setView = SetView(frame: grid[cardFrame]!.insetBy(dx: 5.0, dy: 5.0))
 setView.backgroundColor = .clear
 
 if let card = gameDeck.drawCard() {
 setView = updateCardAttribute(fromCard: card, toCard: setView)
 setView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTap)))
 self.contentView.addSubview(setView)
 cardsInPlay.append(setView)
 }
 }
 
 //Set up the siwpe Down gesture
 updateCardsInDeckStatus()
 toggleDealButton()
 contentView.setNeedsDisplay()
 }
 
 
 private func _reCalculateGrid(byAddingNewCards shouldAddNewCard: Bool = false) {
 
 var columnCount = 0
 var rowCount = 0
 let expectedCardsInPlay = shouldAddNewCard ? cardsInPlay.count + 3 : cardsInPlay.count
 
 if expectedCardsInPlay > 15 {
 columnCount = 4
 let remainder = expectedCardsInPlay % columnCount
 
 switch remainder {
 case 1...4:
 rowCount = 1
 default:
 rowCount = 0
 }
 
 rowCount +=  Int(expectedCardsInPlay / columnCount)
 } else {
 columnCount = 3
 rowCount = expectedCardsInPlay / 3
 }
 
 gridRowCount = rowCount
 gridColumnCount = columnCount
 
 grid = Grid(layout: Grid.Layout.dimensions(rowCount: gridRowCount, columnCount: gridColumnCount), frame: contentView.bounds)
 
 updateExistingGrid()
 
 if expectedCardsInPlay > cardsInPlay.count {
 for index in cardsInPlay.count..<expectedCardsInPlay {
 setView = SetView(frame: grid[index]!.insetBy(dx: 5.0, dy: 5.0))
 setView.backgroundColor = .clear
 if let newCard = gameDeck.drawCard() {
 setView = updateCardAttribute(fromCard: newCard, toCard: setView)
 setView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cardTap)))
 self.contentView.addSubview(setView)
 cardsInPlay.append(setView)
 }
 }
 
 // since the grid has changed adjust any selected cards border
 updateSelectedCardBorders()
 
 }
 
 updateCardsInDeckStatus()
 toggleDealButton()
 }
 
 */
