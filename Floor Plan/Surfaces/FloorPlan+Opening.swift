//
//  FloorPlan+Opening.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/14.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit
import RoomPlan

extension FloorPlan {
    final class Opening: Surface {
        override func draw() {
            let openingPath = self.createPath(from: self.local.start, to: self.local.end)
            
            // Hide the wall underneath the opening
            let hideWallShape = self.createShapeNode(from: openingPath)
            
            // 一時的に色変えてる
            hideWallShape.strokeColor = .blue// Preference.shared.bgColor
            
            hideWallShape.lineWidth = Preference.shared.hideSurfaceWidth
            hideWallShape.zPosition = Preference.shared.zHideSurface
            
            self.addChild(hideWallShape)
        }
    }
}
