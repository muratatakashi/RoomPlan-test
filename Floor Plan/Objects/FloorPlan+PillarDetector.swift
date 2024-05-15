//
//  FloorPlan+PillarDetector.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/15.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit
import RoomPlan

extension FloorPlan {
    final class PillarDetector {
        private(set) var pillars: [Pillar] = []
        
        func predict(from surfaces: [Surface]) {
            self.pillars.removeAll()
            surfaces.forEach {
                guard let wall = $0 as? Wall else { return }
                
                let positions: [CGPoint] = [
                    wall.world.start,
                    wall.world.end
                ]
                
                positions.forEach {
                    let pillar = FloorPlan.Pillar(
                        position: $0,
                        size: CGSize(width: wall.depth, height: wall.depth)
                    )
                    
                    if let index = self.pillars.firstIndex(where: { $0.position == pillar.position}) {
                        if (pillar.size.width < self.pillars[index].size.width
                            || pillar.size.height < self.pillars[index].size.height)
                        {
                            // 同じ場所にあれば小さい方を採用
                            self.pillars[index] = pillar
                        }
                    } else {
                        self.pillars.append(pillar)
                    }
                }
            }
        }
    }
}
