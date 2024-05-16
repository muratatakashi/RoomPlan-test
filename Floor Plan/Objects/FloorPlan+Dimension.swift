//
//  FloorPlan+Dimension.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/04/25.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit

extension FloorPlan {
    class Dimension: SKNode, FloorPlanNodeProtocol {
        var priority: CGFloat {
            Preference.shared.zDimension
        }
        
        let start: CGPoint
        let end: CGPoint
        
        init(from start: CGPoint, to end: CGPoint) {
            self.start = start
            self.end = end
            
            super.init()
            
            self.draw()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func draw() {
            
            let path = self.createPath(
                from: self.start,
                to: self.end
            )
            let shape = self.createShapeNode(from: path)
            shape.lineWidth = Preference.shared.dimensionWidth
            shape.strokeColor = Preference.shared.dimensionColor

            let start = SKShapeNode(circleOfRadius: Preference.shared.dimensionWidth * 5)
            start.fillColor = Preference.shared.dimensionColor
            start.position = self.start

            let end = SKShapeNode(circleOfRadius: Preference.shared.dimensionWidth * 5)
            end.fillColor = Preference.shared.dimensionColor
            end.position = self.end
            
            self.zPosition = self.priority
            
            self.addChild(shape)
            self.addChild(start)
            self.addChild(end)
        }
    }

}
