//
//  FloorPlan+Window.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/14.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit
import RoomPlan

extension FloorPlan {
    final class Window: Surface {
        override var priority: CGFloat {
            Preference.shared.zWindow
        }
        
        override func draw() {
            guard self.surface.confidence == .medium else { return }
            
            super.draw()
            
            let windowPath = self.createPath(from: self.local.start, to: self.local.end)
            
//            // Hide the wall underneath the window
//            let hideWallShape = self.createShapeNode(from: windowPath)
//            hideWallShape.strokeColor = Preference.shared.bgColor
//            hideWallShape.lineWidth = Preference.shared.hideSurfaceWidth
//            hideWallShape.zPosition = Preference.shared.zHideSurface
            
            // The window itself
            let windowShape = self.createShapeNode(from: windowPath)
            windowShape.lineWidth = Preference.shared.otherDepth
            windowShape.strokeColor = Preference.shared.windowColor
//            let windowShape = self.createBoxLineNode(
//                from: self.local.start,
//                to: self.local.end,
//                width: Preference.shared.windowRectWidth
//            )
            windowShape.zPosition = self.priority

//            self.addChild(hideWallShape)
            self.addChild(windowShape)
        }
    }
}
