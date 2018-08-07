//
//  AnimationConstants.swift
//  Sets
//
//  Created by Nikhil Muskur on 24/07/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

struct Constants {
    static var flyDurationTimer: TimeInterval = 3.5
    static var cardFlipDuration: TimeInterval = 0.5
    static var cardFadeDuration: TimeInterval = 0.5
    static var cardDealDuration: TimeInterval = 0.3
    static var cardDealDamping: CGFloat = 0.8
    static var snapBehaviourDampingRatio: CGFloat = 1.8
    static var cardInset: CGFloat = 5.0
    static var pushInitialMagnitude: CGFloat {
        if DeviceType.IS_IPAD_PRO_9_7 || DeviceType.IS_IPAD_PRO_12_9 {
            return 6.0
        } else {
            return 3.0
        }
    }
    static var cardElasticity: CGFloat {
        if DeviceType.IS_IPAD_PRO_9_7 || DeviceType.IS_IPAD_PRO_12_9 {
            return 1.5
        } else {
            if DeviceType.IS_IPHONE_5 {
                return 1.0
            } else if DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_7 {
                return 1.05
            }
            return 1.1
        }
    }
    static var cardFriction: CGFloat = 0.0
}

struct ScreenSize {
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType {
    static let IS_IPHONE            = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_7          = IS_IPHONE_6
    static let IS_IPHONE_8          = IS_IPHONE_6
    static let IS_IPHONE_7P         = IS_IPHONE_6P
    static let IS_IPHONE_8P         = IS_IPHONE_6P
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO_9_7      = IS_IPAD
    static let IS_IPAD_PRO_12_9     = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
    static let IS_TV                = UIDevice.current.userInterfaceIdiom == .tv
    static let IS_CAR_PLAY          = UIDevice.current.userInterfaceIdiom == .carPlay
}

extension UIColor {
    static func initializeTheColor(_red red: CGFloat, _green green: CGFloat, _blue blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
    }
}
