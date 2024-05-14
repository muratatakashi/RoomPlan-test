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
    
    static func convertWorld(localSurface surface: FloorPlan.Surface) -> FloorPlan.Surface {
        switch surface.surface.category {
        case .door:
            FloorPlan.Door(
                capturedSurface: surface.surface,
                from: surface.world.start,
                to: surface.world.end
            )
            
        case .opening:
            FloorPlan.Opening(
                capturedSurface: surface.surface,
                from: surface.world.start,
                to: surface.world.end
            )
            
        case .window:
            FloorPlan.Window(
                capturedSurface: surface.surface,
                from: surface.world.start,
                to: surface.world.end
            )
            
        default:
            FloorPlan.Wall(
                capturedSurface: surface.surface,
                from: surface.world.start,
                to: surface.world.end
            )
        }
    }
}
