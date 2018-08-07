//
//  SetGameViewController.swift
//  Sets
//
//  Created by Nikhil Muskur on 17/07/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import UIKit

enum renderState {
    case initial
    case dealCards
    
    var cardCount: Int {
        switch self {
        case .initial:
            if DeviceType.IS_IPAD || DeviceType.IS_IPAD_PRO_9_7 || DeviceType.IS_IPAD_PRO_12_9 {
                return 28
            } else {
                return 12
            }
        case .dealCards:
            return 3
        }
    }
}

class SetGameViewController: UIViewController, UIDynamicAnimatorDelegate {
    
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var dealMe3CardsButton: UIButton!
    @IBOutlet private weak var bottomStackView: UIStackView!
    @IBOutlet private weak var cardPile: UIButton! {
        didSet {
            cardPile.setTitle("(0) Sets", for: .normal)
        }
    }
    var setCount: Int = 0 {
        didSet {
            cardPile.setTitle("(\(setCount)) Sets", for: .normal)
        }
    }
    @IBOutlet private weak var deckCountStatus: UILabel!
    
    @IBAction private func dealMe3CardsButtonTapped(_ sender: UIButton) {
        if gridView.cardsInPlay.count >= 24 && gameModel.matchedCards.count == 0 {
            showMaxDrawnCardAlert()
        } else if gameModel.matchedCards.count == 3 {
            // if any existing matched cards are present on the deck then replace them
            // instead of adding new cards
            updateViewFromModel()
        } else {
            // add new cards to the deck
            renderCards(renderState.dealCards)
        }
    }
    
    @IBAction private func restartButtonPressed(_ sender: UIButton) {
        contentView.subviews.forEach { (card) in
            cardBehaviour.addItem(card)
            cardBehaviour.addGravityItem(card)
        }
        
        //reset the Set Counter
        setCount = 0
        
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { (timer) in
            self.contentView.subviews.forEach { (card) in
                self.cardBehaviour.removeItem(card)
                self.cardBehaviour.removeGravityItem(card)
                card.removeFromSuperview()
            }
            
            self.initialize()
            // Improve this.
            self.gridView = GridView(grid: self.contentView)
            self.renderCards(renderState.initial)
        }
    }
    
    private var gameModel: Deck!
    private var gridView: GridView!
    private lazy var animator = UIDynamicAnimator(referenceView: view)
    private lazy var cardBehaviour = CardBehaviour(with: animator)
    //temp storage for the cards to fly
    var _cardsToFly = [SetView]()


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initialize()
        animator.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //passing the view directly might have some issues in the future
        gridView = GridView(grid: contentView)
        renderCards(renderState.initial)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        // animate while the rotation animation is happening
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animateAlongsideTransition(in: self.view, animation: { _ in
            self.gridView.recalculateGrid(with: self.contentView)
        })
    }
    
    func initialize() {
        //remove any existing views
        //TODO: add some animation while restarting the game #done
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })
        gameModel = Deck()
    }
    
    
    @objc private func cardTap(tap: UITapGestureRecognizer) {
        let cardsInPlay = gridView.cardsInPlay
        
        if let tapView = tap.view as? SetView, cardsInPlay.contains(tapView) {
            let isSelected = gameModel.selectedCards.contains(tapView.identifier)
            let isMatched = gameModel.matchedCards.contains(tapView.identifier)
            
            if isSelected && gameModel.selectedCards.count < 3 {
                if let indexToRemove = gameModel.selectedCards.index(of: tapView.identifier) {
                    gameModel.selectedCards.remove(at: indexToRemove)
                } else {
                    print("Cannot Find the Card Index to deselect")
                }
            } else if !isMatched {
                gameModel.pickCard(cardIdentier: tapView.identifier)
            }
            
            updateViewFromModel()
        }
    }
    
    func renderCards(_ gameState: renderState) {
        //add new cards to the grid after the deal me three cards button is pressed.
        let cardsToRenderCount = gameState.cardCount
        
        //TODO :  Add LOOP to add more than one card otherwise only one card will be added. #done
        if case .dealCards = gameState {
            gridView.calculateGrid()
        }
        
        gridView.reloadExistingGrid {
            self.createNewCards(cardsToRenderCount)
        }
    }
    
    func createNewCards(_ cardsToRender: Int) {
        var cardsToAnimate = [SetView]()
        
        for _ in 0..<cardsToRender {
            print("Cards Count is: \(gridView.cardsInPlay.count)")
            if let modelCard = gameModel.drawCard() {
                if let frame = gridView.getFrame(forIndex: gridView.cardsInPlay.count) {
                    var displayCard = SetView(frame: frame.insetBy(dx: Constants.cardInset, dy: Constants.cardInset))
                    displayCard.backgroundColor = UIColor.clear
                    displayCard = gridView.updateSetViewFromCard(displayCard, modelCard)
                    // add the Tap Gesture
                    displayCard.addGestureRecognizer(
                        UITapGestureRecognizer(target: self, action: #selector(cardTap(tap:))))
                    // add as an SubView of the ContentView (will be added in the animation func)
                    //contentView.addSubview(displayCard)
                    gridView.cardsInPlay.append(displayCard)
                    cardsToAnimate.append(displayCard)
                } else {
                    print("Cannot find the GRID frame for the ")
                }
            }
        }
        
        animateDealCards(cardsToAnimate)
        updateViewFromModel()
        //check if the user can't create any more
    }
    
    func animateDealCards(_ cards: [SetView]) {
        guard gridView.cardsInPlay.count > 0, cards.count > 0 else {
            print("No Cards passed to Animate: \(#function)")
            return
        }
        
        // deal out the initial 12 cards or 3 new cards
        var cards = cards
        let card = cards.removeFirst()
        let originalFrameForCard = card.frame
        
        let hiddenRect = CGRect(
            x: card.frame.minX,
            y: contentView.frame.maxY,
            width: card.frame.size.width,
            height: card.frame.size.width)
        card.frame = hiddenRect
        
        // IMP: add the card to the contentView ?
        card.removeRoundedBorder() //remove if any border.
        contentView.addSubview(card)
        
        let animator = UIViewPropertyAnimator(
                            duration: Constants.cardDealDuration,
                            dampingRatio: Constants.cardDealDamping) {
            card.alpha = 1
            card.frame = originalFrameForCard
        }
        
        animator.startAnimation()
        animator.addCompletion { _ in
            self.animateDealCards(cards)
        }
    }
    
    func updateViewFromModel() {
        let cardsInPlay = gridView.cardsInPlay
        guard cardsInPlay.count > 0 else { return }
        
        for (_ , card) in cardsInPlay.enumerated() {
            if gameModel.selectedCards.contains(card.identifier) {
                var borderColor = UIColor.black
                let identifier = card.identifier
                if gameModel.selectedCards.count == 3 {
                    borderColor =
                        gameModel.matchedCards.contains(identifier) ? setColor : nonSetColor
                }
                card.drawRoundedBorder(withColor: borderColor)
            } else {
                // otherwise deselect the card(remove the border)
                card.removeRoundedBorder()
            }
        }
        
        if gameModel.matchedCards.count == 3 {
            //update out set counter
            setCount += 1
            replaceMatchedCards()
        }
        updateDeckCountStatus()
        toggleDealButton()
    }
    
    func replaceMatchedCards() {
        var cardsToAnimate = [SetView]()
        var flag = 0
        
        gameModel.matchedCards.forEach { (identifier) in
            if let cardIndex = gridView.cardsInPlay.index(where: { $0.identifier == identifier}) {
                let card = gridView.cardsInPlay[cardIndex]
                cardsToAnimate.append(card)
            } else {
                print("Cannot find the index for the matched card: \(#function)")
            }
        }
        
        animateFlyCards(cardsToAnimate) {
            
            cardsToAnimate.forEach({ (_card) in
                var card = _card
                if let modelCard = self.gameModel.drawCard() {
                    card = self.gridView.updateSetViewFromCard(card, modelCard)
                } else {
                    //TODO: Remove from the Content View as well #done
                    flag = 1
                    let index = self.gridView.cardsInPlay.index(of: card)
                    self.gridView.cardsInPlay.remove(at: index!)
                    card.removeFromSuperview()
                    print("Cannot Draw a card from the model: \(#function) : \(#line)")
                }
            })
            
            if flag == 1 {
                //FIX_THIS : A TEMP Hack
                self.renderCards(renderState.dealCards)
            } else {
                self.animateDealCards(cardsToAnimate)
            }
        
            self.gameModel.matchedCards.removeAll()
            self.updateViewFromModel()
        }
    }
    
    func animateFlyCards(_ cards: [SetView], _ completionBlock: @escaping () -> Void) {
        guard gridView.cardsInPlay.count > 0, cards.count > 0 else {
            print("No Cards passed to Animate: \(#function)")
            return
        }
        
        var cardsToFly = [SetView]()
     
        cards.forEach { (card) in
            let newCard = SetView(frame: card.frame)
            newCard.fillType = card.fillType
            newCard.identifier = card.identifier
            newCard.shape = card.shape
            newCard.shapeColor = card.shapeColor
            newCard.shapeCount = card.shapeCount
            newCard.backgroundColor = UIColor.clear
            
            self.contentView.addSubview(newCard)
            newCard.layer.zPosition = 2
            //TODO: add the cards to the card behaviour (for the push behaviour) #done
            cardBehaviour.addItem(newCard)
            cardsToFly.append(newCard)
        }
        
        Timer.scheduledTimer(
            withTimeInterval: Constants.flyDurationTimer,
            repeats: false) { (timer) in
            
            cardsToFly.forEach({ (flyCard) in
                //TODO: remove all the behaviour from the animator #done (1 by 1)
                self.cardBehaviour.removeItem(flyCard)
                
                UIView.transition(
                    with: flyCard,
                    duration: Constants.cardFlipDuration,
                    options: [UIViewAnimationOptions.transitionFlipFromLeft],
                    animations: {
                        flyCard.faceUp = false
                    },
                    completion: { _ in
                        let buttonCenter = self.bottomStackView.subviews[1].center
                        let snapCenter = CGPoint(
                            x: self.bottomStackView.center.x +
                                (buttonCenter.x - self.bottomStackView.bounds.midX),
                            y: self.bottomStackView.center.y)
                        let snapBehaviour = UISnapBehavior(item: flyCard, snapTo: snapCenter)
                        snapBehaviour.damping = Constants.snapBehaviourDampingRatio
                        snapBehaviour.action = {
                            self.cardPile.alpha = 0
                            flyCard.bounds = self.cardPile.bounds
                            flyCard.faceUp = true
                        }
                        
                        self.animator.addBehavior(snapBehaviour)
                        self._cardsToFly = cardsToFly
                    }
                )
            })
        }
        
        let alphaAnimation = UIViewPropertyAnimator(duration: Constants.cardFadeDuration, curve: .easeIn) {
            cards.forEach({ (card) in
                card.alpha = 0
            })
        }
        
        alphaAnimation.startAnimation()
        alphaAnimation.addCompletion { _ in
            print("Now executing completion block for alphaAnimation")
            completionBlock()
        }
        
    }
}

extension SetGameViewController {
    
    var isDealCardPossible: Bool {
        return gameModel.cards.count > 0
    }
    
    private var setColor: UIColor {
        return UIColor.initializeTheColor(_red: 0, _green: 120, _blue:0)
    }
    
    private var nonSetColor: UIColor {
        return UIColor.initializeTheColor(_red: 125, _green: 0, _blue: 0)
    }
    
    private func toggleDealButton() {
        dealMe3CardsButton.isEnabled = isDealCardPossible
    }
    
    func updateDeckCountStatus() {
        deckCountStatus.text = "Deck: \(gameModel.cards.count)"
    }
    
    func showMaxDrawnCardAlert() {
        let alert = UIAlertController(
            title: "Warning",
            message: "Maximun cards Drawn, find a Set to draw more cards",
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        print("Called \(#function)")
        var localFlyCards = _cardsToFly
        let snapBehaviourCards = animator.behaviors.filter { (behavior) -> Bool in
            if let _ = behavior as? UISnapBehavior {
                return true
            } else {
                return false
            }
        }
        
        if !animator.isRunning {
            if snapBehaviourCards.count >= 3 {
                snapBehaviourCards.forEach {
                    animator.removeBehavior($0)
                }
                self.cardPile.layer.zPosition = 3
                let fadeBackAnimation = UIViewPropertyAnimator(duration: Constants.cardFadeDuration, curve: .easeInOut, animations: {
                    self.cardPile.alpha = 1
                    self.cardPile.layer.zPosition = 1
                })
                fadeBackAnimation.startAnimation()
                
                fadeBackAnimation.addCompletion { _ in
                    //clean up
                    self.contentView.subviews.forEach { (card) in
                        if localFlyCards.contains(card as! SetView) {
                            card.removeFromSuperview()
                            let index = localFlyCards.index(of: card as! SetView)
                            localFlyCards.remove(at: index!)
                            print("Card deleted")
                        }
                    }
                }
            }
        }
    }
}
