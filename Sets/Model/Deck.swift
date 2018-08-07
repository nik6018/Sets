//
//  Deck.swift
//  Sets
//
//  Created by Nikhil Muskur on 20/03/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import Foundation
import GameplayKit

class Deck {
    
    var cards : [Card]
    var shadowDeck : [Card]
    var matchedCards = [Int]()
    var selectedCards = [Int]()
    
    private let numberOfCardsInDeck = 81
    
    func pickCard(cardIdentier: Int) {
        
        if selectedCards.count < 3 {
            if selectedCards.contains(cardIdentier) {
                return
            }
            selectedCards.append(cardIdentier)
        } else {
            selectedCards = [Int]()
            selectedCards.append(cardIdentier)
        }
        
        if isSet(selectedCards) {
            selectedCards.forEach { matchedCards.append($0)  }
        } else {
            print("The Count of Selected Card: \(selectedCards.count)")
        }
    }
    
    func drawCard() -> Card? {
        if cards.count > 0 {
            let card = cards.removeLast()
            return card
        } else {
            return nil
        }
    }
    
    func getCardsLeft() -> Int {
        return cards.count
    }
    
    func quickCheckForSet(for cardIdentifiers: [Int]) -> Bool {
        return isSet(cardIdentifiers)
    }
     
    func isSet(_ selectedCards: [Int]) -> Bool {
        if selectedCards.count == 3 {
            return true
        } else {
            return false
        }
        
        guard selectedCards.count == 3 else {
            print("in guard else")
            return false
        }
        
        
        var cardsToMatch = [Card]()
        
        for index in selectedCards {
            cardsToMatch += shadowDeck.filter { (myCard) -> Bool in
                return myCard.identifier == index
            }
        }
         
        
        // first check for shape count
        if checkShapeCount(cardsToMatch) {
            print("Same or all different Shape Count")
            if checkColor(cardsToMatch){
                print("Same or all different Color")
                if checkPattern(cardsToMatch) {
                    print("Same or all different Pattern")
                    if checkShape(cardsToMatch){
                        print("Same or all different shape")
                        return true
                    } else {
                        print("Not a Set")
                        return false
                    }
                } else {
                    print("Not a Set")
                    return false
                }
            } else {
                print("Not a Set")
                return false
            }
        } else {
            print("Not a Set")
            return false
        }  
    }
    
    func checkAttribute(_ cardsToMatch: [Card],
                        sameAttributeToCheck: (Card) -> Bool,
                        diffAttributeToCheck: (Card) -> Bool) -> Bool {
        
        let allSame = !cardsToMatch.contains(where: sameAttributeToCheck)
        let allDifferent = !cardsToMatch.contains(where: diffAttributeToCheck)
        
        return allSame || allDifferent
    }
    
    
    func checkShapeCount(_ cardsToMatch: [Card]) -> Bool {
        
        let card1 = cardsToMatch[0]
        let card2 = cardsToMatch[1]
        let card3 = cardsToMatch[2]
        
        if card1.cardAttributes?.shapeCount == card2.cardAttributes?.shapeCount, card2.cardAttributes?.shapeCount == card3.cardAttributes?.shapeCount {
            return true
        } else if card1.cardAttributes?.shapeCount != card2.cardAttributes?.shapeCount, card2.cardAttributes?.shapeCount != card3.cardAttributes?.shapeCount, card1.cardAttributes?.shapeCount != card3.cardAttributes?.shapeCount {
            return true
        }
        
        return false
    }
    
    func checkColor(_ cardsToMatch: [Card]) -> Bool {
        
        let card1 = cardsToMatch[0]
        let card2 = cardsToMatch[1]
        let card3 = cardsToMatch[2]
        
        if card1.cardAttributes?.color.rawValue == card2.cardAttributes?.color.rawValue, card2.cardAttributes?.color.rawValue == card3.cardAttributes?.color.rawValue {
            return true
        } else if card1.cardAttributes?.color.rawValue != card2.cardAttributes?.color.rawValue, card2.cardAttributes?.color.rawValue != card3.cardAttributes?.color.rawValue, card1.cardAttributes?.color.rawValue != card3.cardAttributes?.color.rawValue {
            return true
        }
        
        return false
    }
    
    func checkPattern(_ cardsToMatch: [Card]) -> Bool {
        
        let card1 = cardsToMatch[0]
        let card2 = cardsToMatch[1]
        let card3 = cardsToMatch[2]
    
        if card1.cardAttributes?.pattern.rawValue == card2.cardAttributes?.pattern.rawValue, card2.cardAttributes?.pattern.rawValue == card3.cardAttributes?.pattern.rawValue {
            return true
        } else if card1.cardAttributes?.pattern.rawValue != card2.cardAttributes?.pattern.rawValue, card2.cardAttributes?.pattern.rawValue != card3.cardAttributes?.pattern.rawValue, card1.cardAttributes?.pattern.rawValue != card3.cardAttributes?.pattern.rawValue {
            return true
        }
    
        return false
    }
    
    func checkShape(_ cardsToMatch: [Card]) -> Bool {
        
        let card1 = cardsToMatch[0]
        let card2 = cardsToMatch[1]
        let card3 = cardsToMatch[2]
        
        if card1.cardAttributes?.shape.rawValue == card2.cardAttributes?.shape.rawValue, card2.cardAttributes?.shape.rawValue == card3.cardAttributes?.shape.rawValue {
            return true
        } else if card1.cardAttributes?.shape.rawValue != card2.cardAttributes?.shape.rawValue, card2.cardAttributes?.shape.rawValue != card3.cardAttributes?.shape.rawValue, card1.cardAttributes?.shape.rawValue != card3.cardAttributes?.shape.rawValue {
            return true
        }
        
        return false
    }
    
    init() {
        cards = [Card]()
        shadowDeck = [Card]()
        
        // TODO : Create all 81 cards
        for color in CardAttributes.CardColor.all {
            for shape in CardAttributes.CardShape.all {
                for numberOfShapes in 1...3 {
                    for pattern in CardAttributes.CardPattern.all {
                        let attribute = CardAttributes(color: color, shape: shape, pattern: pattern, shapeCount: numberOfShapes)
                        
                        var card = Card()
                        card.cardAttributes = attribute
                        
                        cards.append(card)
                    }
                }
            }
        }
        
        // TODO : Shuffle all the cards
        cards = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: cards) as! [Card]
        // shadow deck to match our cards
        shadowDeck = cards
    }
}
