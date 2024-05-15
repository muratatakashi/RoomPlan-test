//
//  CGPoint+extensions.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/15.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit

extension CGPoint {
    static func ==(lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(
            x: lhs.x + rhs.x,
            y: lhs.y + rhs.y
        )
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(
            x: lhs.x - rhs.x,
            y: lhs.y - rhs.y
        )
    }
    
    static func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(
            x: point.x * scalar,
            y: point.y * scalar
        )
    }
        
    static func *(scalar: CGFloat, point: CGPoint) -> CGPoint {
        return CGPoint(
            x: point.x * scalar,
            y: point.y * scalar
        )
    }
    
    static func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(
            x: point.x / scalar,
            y: point.y / scalar
        )
    }
    
    func length() -> CGFloat {
        return CGFloat(
            distance(
                SIMD2<Float>(0, 0),
                SIMD2<Float>(Float(self.x), Float(self.y))
            )
        )
    }
    
    func normalized() -> CGPoint {
        return CGPoint(
            x: self.x / self.length(),
            y: self.y / self.length()
        )
    }
    
    func angle(to point: CGPoint) -> CGFloat {
        return atan2(point.y - self.y, point.x - self.x)
    }
}

extension CGFloat {
    var degree: CGFloat {
        self * 180 / .pi
    }
    
    var radian: CGFloat {
        self * .pi / 180
    }
}
