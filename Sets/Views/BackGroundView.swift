//
//  BackGroundView.swift
//  Sets
//
//  Created by Nikhil Muskur on 02/05/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import UIKit

@IBDesignable
class BackGroundView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.initializeTheColor(_red: 252, _green: 79, _blue:8) { didSet { setNeedsDisplay() } }
    @IBInspectable var endColor: UIColor = UIColor.orange { didSet { setNeedsDisplay() } }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let colors = [endColor.cgColor, startColor.cgColor]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let colorLocations: [CGFloat] = [0.0, 1.0]
        
        let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: colors as CFArray,
            locations: colorLocations)!
        
        let startPoint = CGPoint.zero
        let endPoint = CGPoint(x: 0 , y: bounds.height)
        context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
    }    
}
