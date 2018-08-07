//
//  Card.swift
//  Sets
//
//  Created by Nikhil Muskur on 20/03/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import Foundation

struct Card: Hashable, CustomStringConvertible {
    
    var description: String {
        return "Card has the Following Attribute with Color: \(self.cardAttributes!.color.rawValue) , Shape: \(self.cardAttributes!.shape.rawValue) and Pattern : \(self.cardAttributes!.pattern.rawValue), with shapeCount: \(self.cardAttributes!.shapeCount)"
    }
    
    
    var hashValue: Int {
        return identifier
    }
    
    static func ==(lhs: Card, rhs: Card) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    
    var cardAttributes: CardAttributes?
    var isSelected = false
    var identifier: Int
    
    static var identifierFactory = 0
    
    static func getIdentifier() -> Int {
        identifierFactory += 1
        return identifierFactory
    }
    
    init() {
        self.identifier = Card.getIdentifier()
    }
}

