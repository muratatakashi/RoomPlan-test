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
        override func draw() {
            let wallPath = self.createPath(from: self.local.start, to: self.local.end)
            let wallShape = self.createShapeNode(from: wallPath)
            wallShape.lineCap = .square
            self.addChild(wallShape)
        }
    }
}
