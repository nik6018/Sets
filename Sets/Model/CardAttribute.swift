//
//  CardAttribute.swift
//  Sets
//
//  Created by Nikhil Muskur on 13/07/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import Foundation

struct CardAttributes {
    
    var color: CardColor
    var shape: CardShape
    var pattern: CardPattern
    var shapeCount: Int
    
    enum CardColor: String {
        case red = "red", green = "green", blue = "blue"
        
        static var all : [CardColor] = [CardColor.red, .green, .blue]
    }
    
    enum CardShape: String {
        case circle   = "●", square   = "■", triangle = "▲"
        
        static var all : [CardShape] = [CardShape.circle, .square, .triangle]
    }
    
    enum CardPattern: String {
        case filled = "filled", stripped = "stripped", outline = "outline"
        
        static var all : [CardPattern] = [CardPattern.filled, .stripped, .outline]
    }
    
    init(color: CardColor, shape: CardShape, pattern: CardPattern, shapeCount: Int) {
        self.color = color
        self.shape = shape
        self.pattern = pattern
        self.shapeCount = shapeCount
    }
}
