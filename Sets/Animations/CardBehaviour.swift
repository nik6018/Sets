//
//  CardBehaviour.swift
//  Sets
//
//  Created by Nikhil Muskur on 25/05/18.
//  Copyright © 2018 Nikhil Muskur. All rights reserved.
//

import UIKit

class CardBehaviour: UIDynamicBehavior {

    private lazy var gravityBehavior: UIGravityBehavior = {
        let behavior = UIGravityBehavior()
        behavior.setAngle(.pi/2, magnitude: 1.5)
        return behavior
    }()
    
    private lazy var collisionBehaviour: UICollisionBehavior = {
        let behaviour = UICollisionBehavior()
        behaviour.translatesReferenceBoundsIntoBoundary = true
        return behaviour
    }()
    
    private lazy var itemBehaviour: UIDynamicItemBehavior = {
        var behaviour = UIDynamicItemBehavior()
        behaviour.allowsRotation = true
        behaviour.friction = Constants.cardFriction
        behaviour.elasticity = Constants.cardElasticity
        return behaviour
    }()

    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        let angle = getPushAngle(item)
        push.angle = angle
        push.magnitude = Constants.pushInitialMagnitude + CGFloat(2.0).arc4random
        push.action = { [unowned push, weak self] in
            self?.removeChildBehavior(push)
        }
        addChildBehavior(push)
    }
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehaviour.addItem(item)
        // added this boundary for more fine tuned animation.
        itemBehaviour.addItem(item)
        push(item)
    }
    
    func removeItem(_ item: UIDynamicItem)  {
        collisionBehaviour.removeItem(item)
        itemBehaviour.removeItem(item)
    }
    
    func addGravityItem(_ item: UIDynamicItem) {
        itemBehaviour.elasticity = 1.0
        gravityBehavior.addItem(item)
    }
    
    func removeGravityItem(_ item: UIDynamicItem) {
        gravityBehavior.removeItem(item)
        itemBehaviour.elasticity = Constants.cardElasticity
    }
    
    override init() {
        super.init()
        addChildBehavior(collisionBehaviour)
        addChildBehavior(itemBehaviour)
        addChildBehavior(gravityBehavior)
    }
    
    convenience init(with animator: UIDynamicAnimator) {
        self.init()
        
        animator.addBehavior(self)
    }
}

extension CardBehaviour {
    
    func getPushAngle(_ item: UIDynamicItem) -> CGFloat {
        if let referenceViewBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceViewBounds.midX, y: referenceViewBounds.midY)
            
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                return (CGFloat(180.arc4random) * (CGFloat.pi/180))
            case let (x, y) where x < center.x && y > center.y:
                return CGFloat.pi - (CGFloat(180.arc4random) * (CGFloat.pi/180))
            case let (x, y) where x > center.x && y < center.y:
                return -(CGFloat(180.arc4random) * (CGFloat.pi/180))
            case let (x, y) where x > center.x && y > center.y:
                return CGFloat.pi + (CGFloat(180.arc4random) * (CGFloat.pi/180))
            default:
                return (2*(CGFloat(180.arc4random) * (CGFloat.pi/180)))
            }
        }
        return (2*CGFloat.pi)
    }
}
