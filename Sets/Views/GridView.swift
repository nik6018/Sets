//
//  GridView.swift
//  Sets
//
//  Created by Nikhil Muskur on 04/05/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import UIKit

class GridView: UIView {
    
    private var isGameInIntialState: Bool {
        return cardsInPlay.count == 0
    }
    
    private var numberOfCardsThatCanBeAddedToView = 3
    private var rowCount = 4
    private var columnCount = 3
    var cardsInPlay: [SetView] = []
    var gridLayoutFrame: Grid!
    var contentView: UIView!
    
    func calculateGrid() {
        print("Called \(#function), with card count: \(cardsInPlay.count)")
        // TOCHECK :
        // if the initial grid is calculated in the init then no need of checking the
        // game state here as this method will always be called when a user deals cards more
        // cards
        
        // Calculate the GRID
        var expectedCardsInPlay = 0
        
        if !isGameInIntialState {
            expectedCardsInPlay =  cardsInPlay.count + numberOfCardsThatCanBeAddedToView
            
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
                // 5 Rows and 3 columns doesn't look good on the below devices
                if DeviceType.IS_IPHONE_5 || DeviceType.IS_IPHONE_6 {
                    columnCount = 4
                } else {
                    columnCount = 3
                }
                rowCount = expectedCardsInPlay / 3
            }
        }
      
        let layout = Grid.Layout.dimensions(rowCount: rowCount, columnCount: columnCount)
        gridLayoutFrame = Grid(layout: layout, frame: contentView.bounds)
    }

    
    func reloadExistingGrid(_ completionBlock: @escaping () -> Void) {
        guard cardsInPlay.count > 0 else {
            print("No Cards present to Adjust the Grid")
            completionBlock()
            return
        }
        
        // reload the grid postion of the the existing views
        let animator = UIViewPropertyAnimator(duration: 0.7, dampingRatio: 0.5, animations: nil)
        
        for (index, card) in cardsInPlay.enumerated() {
            if let frame = gridLayoutFrame[index] {
                animator.addAnimations {
                    card.frame = frame.insetBy(dx: 5.0, dy: 5.0)
                }
                animator.startAnimation()
                card.setNeedsDisplay()
                contentView.addSubview(card)
            }
        }
        
        animator.addCompletion { _ in
            // add the new cards animation
            completionBlock()
        }
    }
    
    func updateSetViewFromCard(_ setView: SetView, _ card: Card) -> SetView{
        setView.identifier = card.identifier
        
        switch card.cardAttributes!.color {
        case .red: setView.shapeColor = UIColor.red
        case .blue: setView.shapeColor = UIColor.blue
        case .green: setView.shapeColor = UIColor.initializeTheColor(_red: 0, _green: 95, _blue: 0)
        }
        
        switch card.cardAttributes!.shape {
        case .circle:   setView.shape = "circle"
        case .square:   setView.shape = "square"
        case .triangle: setView.shape = "triangle"
        }
        
        switch card.cardAttributes!.pattern {
        case .filled:   setView.fillType = "filled"
        case .outline:  setView.fillType = "empty"
        case .stripped: setView.fillType = "stripped"
        }
        
        setView.shapeCount = card.cardAttributes!.shapeCount
        return setView
    }
    
    func getFrame(forIndex index: Int) -> CGRect? {
        return gridLayoutFrame[index]
    }
    
    func recalculateGrid(with view: UIView) {
        contentView = view
        numberOfCardsThatCanBeAddedToView = 0
        calculateGrid()
        reloadExistingGrid { /*no code after reload*/ }
        numberOfCardsThatCanBeAddedToView = 3
    }
    
    // pass any use info during initialization
    convenience init(grid: UIView){
        self.init()
        
        //can layout be done here?
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            rowCount = 7
            columnCount = 4
        }
        
        self.contentView = grid
        let layout = Grid.Layout.dimensions(rowCount: rowCount, columnCount: columnCount)
        print("the Layout: \(rowCount * columnCount)")
        gridLayoutFrame = Grid(layout: layout, frame: contentView.bounds)
    }
    
}
