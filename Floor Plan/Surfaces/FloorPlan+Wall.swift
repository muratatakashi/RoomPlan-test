//
//  FloorPlan+Wall.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/14.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit
import RoomPlan

extension FloorPlan {
    final class Wall: Surface {
        
        override var priority: CGFloat {
            Preference.shared.zWall
        }
        
        var depth: CGFloat {
            guard self.surface.dimensions.z != 0 else {
                return Preference.shared.defaultWallDepth
            }
            return CGFloat(self.surface.dimensions.z) * Preference.shared.m2mm
        }
        
        // 没
        var wallLocal: SurfacePoint {
            let v = (self.local.end - self.local.start).normalized()
            return SurfacePoint(
                start: self.local.start - (v * (self.depth / 2)),
                end: self.local.end + (v * (self.depth / 2))
            )
        }

        override func draw() {
            super.draw()
            
            let wallShape = self.createBoxLineNode(
                from: self.wallLocal.start,
                to: self.wallLocal.end,
                width: self.depth,
                fillColor: Preference.shared.wallColor
            )
            wallShape.zPosition = self.priority
            
//            let wallPath = self.createPath(from: self.local.start, to: self.local.end)
//            let wallShape = self.createShapeNode(from: wallPath)
//            wallShape.lineCap = .square
            
            self.addChild(wallShape)
        }
    }
}
