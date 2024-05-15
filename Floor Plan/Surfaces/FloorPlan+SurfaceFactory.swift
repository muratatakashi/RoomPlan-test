//
//  FloorPlan+SurfaceFactory.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/14.
//  Copyright © 2024 Apple. All rights reserved.
//

import RoomPlan

extension FloorPlan.Surface {
    static func factory(surface: CapturedRoom.Surface) -> FloorPlan.Surface {
        switch surface.category {
        case .door:
            FloorPlan.Door(capturedSurface: surface)
        case .opening:
            FloorPlan.Opening(capturedSurface: surface)
        case .window:
            FloorPlan.Window(capturedSurface: surface)
        default:
            FloorPlan.Wall(capturedSurface: surface)
        }
    }
    
    static func convertWorld(
        localSurface surface: FloorPlan.Surface,
        module: FloorPlan.Module
    ) -> FloorPlan.Surface {
        
        let start = module.corret(point: surface.world.start)
        let end = module.corret(point: surface.world.end)
        
        return switch surface.surface.category {
        case .door:
            FloorPlan.Door(
                capturedSurface: surface.surface,
                from: start,
                to: end
            )
            
        case .opening:
            FloorPlan.Opening(
                capturedSurface: surface.surface,
                from: start,
                to: end
            )
            
        case .window:
            FloorPlan.Window(
                capturedSurface: surface.surface,
                from: start,
                to: end
            )
            
        default:
            FloorPlan.Wall(
                capturedSurface: surface.surface,
                from: start,
                to: end
            )
        }
    }
}
