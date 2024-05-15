//
//  FloorPlan+Pillar.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/15.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit

extension FloorPlan {
    final class Pillar: SKNode, FloorPlanNodeProtocol {
        var priority: CGFloat {
            Preference.shared.zPillar
        }
        
        private(set) var size: CGSize
        
        init(
            position: CGPoint,
            size: CGSize
        ) {
            self.size = size
            
            super.init()
            
            self.position = position
            
            self.draw()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func draw() {
            let node = SKShapeNode(rectOf: self.size)
            node.lineWidth = Preference.shared.rectLineWidth
            node.strokeColor = Preference.shared.surfaceColor
            node.fillColor = Preference.shared.pillarColor
            
            let verticalPath = self.createPath(
                from: CGPoint(x: 0, y: -(self.size.height / 2)),
                to: CGPoint(x: 0, y: self.size.height / 2)
            )
            let verticalLine = self.createShapeNode(
                from: verticalPath,
                width: Preference.shared.rectLineWidth
            )
            
            let horizontalPath = self.createPath(
                from: CGPoint(x: -(self.size.width) / 2, y: 0),
                to: CGPoint(x: self.size.width / 2, y: 0)
            )
            let horizontalLine = self.createShapeNode(
                from: horizontalPath,
                width: Preference.shared.rectLineWidth
            )
            
            self.zPosition = self.priority
            
            self.addChild(node)
            self.addChild(verticalLine)
            self.addChild(horizontalLine)
        }
    }
}
