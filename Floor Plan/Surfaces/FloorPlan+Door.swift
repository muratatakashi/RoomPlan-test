//
//  FloorPlan+Door.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/14.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit
import RoomPlan

extension FloorPlan {
    final class Door: Surface {
        override func draw() {
            let hideWallPath = self.createPath(from: self.local.start, to: self.local.end)
            let doorPath = self.createPath(from: self.local.start, to: self.local.end)
    //        let doorPath = self.createPath(from: self._startPoint, to: self._doorEndPoint)

            // Hide the wall underneath the door
            let hideWallShape = self.createShapeNode(from: hideWallPath)
            hideWallShape.strokeColor = Preference.shared.bgColor
            hideWallShape.lineWidth = Preference.shared.hideSurfaceWidth
            hideWallShape.zPosition = Preference.shared.zHideSurface
            
            // The door itself
            let doorShape = self.createShapeNode(from: doorPath)
            doorShape.strokeColor = .orange
            doorShape.lineCap = .square
            doorShape.zPosition = Preference.shared.zDoor
            
    //        // The door's arc
    //        let doorArcPath = CGMutablePath()
    //        doorArcPath.addArc(
    //            center: self._startPoint,
    //            radius: self._halfLength * 2,
    //            startAngle: 0.25 * .pi,
    //            endAngle: 0,
    //            clockwise: true
    //        )
            
    //        // Create a dashed path
    //        let dashPattern: [CGFloat] = [
    //            Preference.shared.doorDashWidth,
    //            Preference.shared.doorDashSpan
    //        ]
    //        let dashedArcPath = doorArcPath.copy(dashingWithPhase: 1, lengths: dashPattern)
    //
    //        let doorArcShape = self.createShapeNode(from: dashedArcPath)
    //        doorArcShape.lineWidth = Preference.shared.doorArcWidth
    //        doorArcShape.zPosition = Preference.shared.zDoorArc
            
            self.addChild(hideWallShape)
            self.addChild(doorShape)
    //        self.addChild(doorArcShape)
        }
    }
}
