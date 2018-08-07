//
//  SetView.swift
//  Sets
//
//  Created by Nikhil Muskur on 22/04/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import UIKit

@IBDesignable
class SetView: UIView {
    
    @IBInspectable var shape: String = "circle" { didSet{ setNeedsDisplay();setNeedsLayout() }}
    @IBInspectable var shapeColor: UIColor = .red { didSet{ setNeedsDisplay();setNeedsLayout() }}
    @IBInspectable var fillType: String = "empty" { didSet{ setNeedsDisplay();setNeedsLayout() }}
    @IBInspectable var shapeCount: Int = 3 { didSet{ setNeedsDisplay();setNeedsLayout() }}
    @IBInspectable var faceUp: Bool = true { didSet{ setNeedsDisplay() }}
    
    var identifier: Int = 0
    
    // Called when the view's dimensions change
    override func layoutSubviews() {
        super.layoutSubviews()
        // If in Landscape draw the shapes horizontally
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        // draw the outline card
        drawCard()
        
        if !faceUp {
            return
        }
        
        //Get the drawing region
        var parentRect = getRectForShape()
        let perRowHeight: CGFloat
        let perRowWidth: CGFloat
        
        if isLandscape {
            perRowHeight = parentRect.size.height
            perRowWidth  = parentRect.size.width / CGFloat(shapeCount)
        } else {
            perRowHeight = parentRect.size.height / CGFloat(shapeCount)
            perRowWidth  = parentRect.size.width
        }
        
        // CGSize of the Circle or Square or Triangle
        parentRect.size.height = 2 * centerRadius
        parentRect.size.width  =  2 * centerRadius
        
        /*---------------------------------*/
        // Used below for Translation and Scaling
        var ogOriginX = parentRect.origin.x
        let ogOriginY = parentRect.origin.y
        /*---------------------------------*/
        
        // Divde the drawing region according to the Shape count
        parentRect.origin.y += (perRowHeight - parentRect.size.height) / 2
        parentRect.origin.x += (perRowWidth - parentRect.size.width) / 2
        
        // Draw the shapes
        for shapeNumber in 1...shapeCount {
            
            // Calculate the Rect for traingle, circle or square
            // TODO: reimplement this #done
            let height = 2 * centerRadius
            let width  = height
            
            // Make the Rect a little smaller than the original size to avoid stacking if shapeCount is 3
            var shapeRect = CGRect.zero
            
            if isLandscape {
                shapeRect = CGRect(
                    x: parentRect.origin.x,
                    y: parentRect.origin.y,
                    width: width , height: height)
                
                /* -------------------------------------------------------------------*/
                // Just to show Scaling and Translation to adjust the shape in landscape, not good practise
                shapeRect = shapeRect.applying(CGAffineTransform(scaleX: 1.3, y: 1.3))
                let midPointForXTranslation = (perRowWidth - shapeRect.size.width) / 2
                let xTranslation = shapeRect.origin.x - (ogOriginX + midPointForXTranslation)
                let midPointForYTranslation = (perRowHeight - shapeRect.size.height) / 2
                let yTranslation = shapeRect.origin.y - (ogOriginY + midPointForYTranslation)
                shapeRect = shapeRect.applying(CGAffineTransform(translationX: -xTranslation, y: -yTranslation))
                /* -------------------------------------------------------------------*/
            } else if shapeCount == 3 {
                shapeRect = adjustShapeRectSize(forShapeNumber: shapeNumber, fromParentRect: parentRect)
            } else {
                shapeRect = CGRect(
                    x: parentRect.origin.x,
                    y: parentRect.origin.y,
                    width: width - 4.0 , height: height - 4.0)
            }
            
            let drawingContext = UIGraphicsGetCurrentContext()!
            let shapePath: UIBezierPath
            
            switch shape {
            case "triangle":
                shapePath = UIBezierPath()
                // draw the triangle path
                shapePath.move(to: CGPoint(x: shapeRect.midX, y: shapeRect.origin.y))
                shapePath.addLine(to: CGPoint(x: shapeRect.origin.x, y: shapeRect.maxY))
                shapePath.addLine(to: CGPoint(x: shapeRect.maxX, y: shapeRect.maxY))
                shapePath.close()
                
            case "square":
                shapePath = UIBezierPath(rect: shapeRect)
            case "circle":
                shapePath = UIBezierPath(ovalIn: shapeRect)
            default:
                shapePath = UIBezierPath(rect: shapeRect)
            }
            
            shapePath.lineWidth = lineWidth
            
            drawingContext.saveGState()
            
            let drawingColor = shapeColor
            shapePath.addClip()
            
            switch fillType {
            case "filled":
                drawingColor.setFill()
                shapePath.fill()
            case "empty":
                // small adjust of line width, otherwise the shape appears faded
                shapePath.lineWidth = lineWidth + 2.0
                drawingColor.setStroke()
                shapePath.stroke()
            case "stripped":
                // small adjust of line width, otherwise the shape appears faded
                shapePath.lineWidth = lineWidth + 2.0
                drawingColor.setStroke()
                shapePath.stroke()
                drawStrippedRect(inRect: shapeRect)
            default:
                drawingColor.setStroke()
                shapePath.stroke()
            }
            
            drawingContext.restoreGState()
            if isLandscape {
                parentRect.origin.x += perRowWidth
                ogOriginX += perRowWidth
            } else {
                parentRect.origin.y += perRowHeight
            }
        }
    }
    
    private func drawCard() {
        let roundedRect = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        roundedRect.addClip()
        faceUp ? UIColor.white.setFill() : UIColor.darkGray.setFill()
        roundedRect.fill()
    }
    
    private func drawStrippedRect(inRect rect: CGRect) {
        
        // TODO: Refactor
        let lineWidth = self.lineWidth
        
        let stripePath = UIBezierPath()
        stripePath.lineWidth = lineWidth
        stripePath.move(to: CGPoint(x: bounds.midX, y: bounds.minY))
        stripePath.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        
        var midPoint = bounds.midX
        let lineSpacing: CGFloat = lineWidth + 1.0
        
        while midPoint > bounds.minX {
            let nextPoint = midPoint - lineWidth - lineSpacing
            stripePath.lineWidth = lineWidth
            stripePath.move(to: CGPoint(x: nextPoint, y: bounds.minY) )
            stripePath.addLine(to: CGPoint(x: nextPoint, y: bounds.height))
            midPoint -= (lineWidth + lineSpacing)
        }
        
        
        var midPoint1 = bounds.midX
        
        while midPoint1 < bounds.maxX {
            let nextPoint = midPoint1 + lineWidth + lineSpacing
            stripePath.lineWidth = lineWidth
            stripePath.move(to: CGPoint(x: nextPoint, y: bounds.minY) )
            stripePath.addLine(to: CGPoint(x: nextPoint, y: bounds.height))
            midPoint1 += (lineWidth + lineSpacing)
        }
        
        shapeColor.setStroke()
        stripePath.stroke()
    }
    
    private func getRectForShape() -> CGRect {
        let shapeRect = bounds.insetBy(dx: cornerOffset, dy: cornerOffset).insetBy(dx: cornerOffset, dy: cornerOffset)
        return shapeRect
    }
    
    private func adjustShapeRectSize(forShapeNumber number: Int, fromParentRect parentRect: CGRect) -> CGRect {
        var finalRect = CGRect.zero
        let height = 2 * centerRadius
        let width  = height
        
        switch number {
        case 1:
            finalRect = CGRect(
                x: parentRect.origin.x,
                y: parentRect.origin.y + 2.0,
                width: width - 4.0 , height: height - 4.0)
        case 2:
            finalRect = CGRect(
                x: parentRect.origin.x,
                y: parentRect.origin.y + 2.0,
                width: width - 4.0 , height: height - 4.0)
        case 3:
            finalRect = CGRect(
                x: parentRect.origin.x,
                y: parentRect.origin.y + 2.0,
                width: width - 4.0 , height: height - 4.0)
        default:
            finalRect = CGRect.zero
        }
        
        return finalRect
    }
    
    func drawRoundedBorder(withColor borderColor: UIColor) {
        self.layer.cornerRadius = self.cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
    
    func removeRoundedBorder() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0.0
    }
    convenience init(copyCard card: SetView) {
        self.init()
        
        shape = card.shape
        shapeCount = card.shapeCount
        fillType = card.fillType
        shapeColor = card.shapeColor
    }
}

fileprivate extension SetView {
    fileprivate struct SizeRatio {
        static let cornerFontSizeToBoundsHeight: CGFloat = 0.085
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let cornerOffsetToCornerRadius: CGFloat = 0.33
        static let shapeSizeToBoundsSize: CGFloat = 0.15
        static let lineWidthToBoundsWidth: CGFloat = 0.01
        static let selectedCardBorderWidthToBounds: CGFloat = 0.03
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }
    private var cornerOffset: CGFloat {
        return cornerRadius * SizeRatio.cornerOffsetToCornerRadius
    }
    private var cornerFontSize: CGFloat {
        return bounds.size.height * SizeRatio.cornerFontSizeToBoundsHeight
    }
    private var centerRadius: CGFloat {
        if isiPad {
            if (bounds.size.width/bounds.size.height) > 2.5 {
                // spl case when cards snap to cardpile in iPad
                return bounds.size.height * 0.18
            } else {
                return bounds.size.height * 0.10
            }
        } else if isLandscape {
            return bounds.size.height * 0.20
        } else {
            return bounds.size.width * SizeRatio.shapeSizeToBoundsSize
        }
    }
    private var rectWidth: CGFloat {
        if bounds.size.width > bounds.size.height {
            return bounds.size.height * SizeRatio.shapeSizeToBoundsSize
        } else if bounds.size.width < bounds.size.height {
            return bounds.size.width * SizeRatio.shapeSizeToBoundsSize
        }
        
        return bounds.size.width * SizeRatio.shapeSizeToBoundsSize
    }
    private var lineWidth: CGFloat {
        if isLandscape {
            return bounds.width / 2 * SizeRatio.lineWidthToBoundsWidth
        } else {
            return bounds.width * SizeRatio.lineWidthToBoundsWidth
        }
    }
    private var borderWidth: CGFloat {
        if isLandscape {
            return bounds.size.width / 2 * SizeRatio.selectedCardBorderWidthToBounds
        } else {
            return bounds.width * SizeRatio.selectedCardBorderWidthToBounds
        }
    }
    private var isLandscape: Bool {
        if UIDevice.current.orientation.isLandscape  {
            return true
        } else if UIDevice.current.orientation.isPortrait {
            // Additional iPad check as even in potrait
            // the shapes look good horizontally instead of vertical on iPhone
            if isiPad { return true }
            // condition to handle the snap animation
            // where the a landscape card is shown in portrait
            // new : added the ratio check for 4-inch screens considered as landscape
            if bounds.width > bounds.height && (bounds.width/bounds.height) > 2.5 {
                return true
            } else {
                return false
            }
        }
        return false
    }
    private var isiPad: Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad {
            return true
        } else {
            return false
        }
    }
}

fileprivate extension CGRect {
    var leftHalf: CGRect {
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect {
        return CGRect(x: midX, y: minY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect {
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect {
        return CGRect(origin: origin, size: size)
    }
    
    var centerPoint: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    var radiusForCircle: CGFloat {
        if self.size.width > self.size.height {
            return self.size.height * SetView.SizeRatio.shapeSizeToBoundsSize
        } else if self.size.width < self.size.height {
            return self.size.width * SetView.SizeRatio.shapeSizeToBoundsSize
        }
        
        return self.size.width * SetView.SizeRatio.shapeSizeToBoundsSize
    }
    
    func getRectChunk(withHeight: CGFloat) -> CGRect {
        let newRect = CGRect(x: minX, y: minY, width: width, height: withHeight)
        return newRect
    }
    
    func zoom(by scale: CGFloat) -> CGRect {
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
    func zoomBackImage(byWidth scaleWidth: CGFloat, byHeight scaleHeight: CGFloat) -> CGRect {
        let newWidth = width * scaleWidth
        let newHeight = height * scaleHeight
        return insetBy(dx: (width - newWidth) / 2, dy: (height - newHeight) / 2)
    }
}

extension CGPoint {
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x+dx, y: y+dy)
    }
}

extension CGFloat {
    var arc4random: CGFloat {
        if self > CGFloat(0.0) {
            print("IN IF EXT : \(self)")
            return CGFloat(arc4random_uniform(UInt32(self)))
        } else if self < CGFloat(0.0) {
            print("IN ELSE IF EXT : \(self)")
            return -CGFloat(arc4random_uniform(UInt32(abs(self))))
        } else {
            print("IN ELSE EXT : \(self)")
            return 0
        }
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
