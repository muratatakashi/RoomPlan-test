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
        
        override var priority: CGFloat {
            Preference.shared.zDoor
        }
        
        private var _limitWidth: CGFloat {
            1000
        }
        
        var doorLocal: SurfacePoint {
            SurfacePoint(
                start: super.local.start,
                end: super.local.end.rotateAround(
                    point: super.local.start,
                    by: 0.5 * .pi
                )
            )
        }
        
        override func draw() {
//            guard self.surface.confidence == .high else { return }
            
            super.draw()
            
            // Hide the wall underneath the door
            let hideWallPath = self.createPath(from: self.local.start, to: self.local.end)
            let hideWallShape = self.createShapeNode(from: hideWallPath)
            hideWallShape.strokeColor = Preference.shared.bgColor
            hideWallShape.lineWidth = Preference.shared.hideSurfaceWidth
            hideWallShape.zPosition = Preference.shared.zHideSurface
            
            var doorPath = self.createPath(from: self.local.start, to: self.local.end)
            if self.length < self._limitWidth {
                // ある程度サイズが小さかったらドアとして描画
                doorPath = self.createPath(from: self.doorLocal.start, to: self.doorLocal.end)
            }
            
            // The door itself
            let doorShape = self.createShapeNode(from: doorPath)
            doorShape.strokeColor = Preference.shared.doorColor
            doorShape.lineCap = .square
            doorShape.lineWidth = Preference.shared.otherDepth
            doorShape.zPosition = self.priority
            
//            if self.length < self._limitWidth {
//                self.addChild(hideWallShape)
//            }
            self.addChild(doorShape)
            
            if self.length < self._limitWidth {
                // The door's arc
                let angle = self.local.start.angle(to: self.local.end)
                let offsetAngle = 0.5 * .pi
                
                let doorArcPath = CGMutablePath()
                doorArcPath.addArc(
                    center: self.doorLocal.start,
                    radius: self.length,
                    startAngle: angle + offsetAngle,
                    endAngle: angle,
                    clockwise: true
                )
                
                // Create a dashed path
                let dashPattern: [CGFloat] = [
                    Preference.shared.doorDashWidth,
                    Preference.shared.doorDashSpan
                ]
                let dashedArcPath = doorArcPath.copy(dashingWithPhase: 1, lengths: dashPattern)
                
                let doorArcShape = self.createShapeNode(from: dashedArcPath)
                doorArcShape.lineWidth = Preference.shared.doorArcWidth
                doorArcShape.zPosition = Preference.shared.zDoorArc

                self.addChild(doorArcShape)
            }
        }
    }
}
