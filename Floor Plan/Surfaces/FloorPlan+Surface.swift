//
//  FloorPlanSurfaceProtocol.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/14.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit
import RoomPlan

extension FloorPlan {
    struct SurfacePoint {
        var start: CGPoint
        var end: CGPoint
    }
}

extension FloorPlan {
    
    class Surface: SKNode, FloorPlanNodeProtocol {
        var priority: CGFloat {
            Preference.shared.zSurface
        }
        
        private(set) var surface: CapturedRoom.Surface
        
        var length: CGFloat {
            return CGFloat(self.surface.dimensions.x) * Preference.shared.m2mm
        }
        
        private var halfLength: CGFloat {
            self.length / 2
        }
        
        private(set) var local: SurfacePoint = SurfacePoint(
            start: .zero,
            end: .zero
        )
        
        var world: SurfacePoint {
            SurfacePoint(
                start: self.convertWorld(position: self.local.start),
                end: self.convertWorld(position: self.local.end)
            )
        }
        
        init(
            capturedSurface surface: CapturedRoom.Surface
        ) {
            self.surface = surface
            
            super.init()
            
            // Set the surface's position using the transform matrix
            let surfacePositionX = -CGFloat(surface.transform.position.x) * Preference.shared.m2mm
            let surfacePositionY = CGFloat(surface.transform.position.z) * Preference.shared.m2mm
            self.position = CGPoint(x: surfacePositionX, y: surfacePositionY)
            
            // Set the surface's zRotation using the transform matrix
            self.zRotation = -CGFloat(surface.transform.eulerAngles.z - surface.transform.eulerAngles.y)
            
            self.local.start = CGPoint(x: -self.halfLength, y: 0)
            self.local.end = CGPoint(x: self.halfLength, y: 0)
            
            self.draw()
        }
        
        init(
            capturedSurface surface: CapturedRoom.Surface,
            from startPoint: CGPoint,
            to endPoint: CGPoint
        ) {
            self.surface = surface
            
            super.init()
            
            self.local.start = startPoint
            self.local.end = endPoint

            self.draw()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func draw() {
        }
    }
}
