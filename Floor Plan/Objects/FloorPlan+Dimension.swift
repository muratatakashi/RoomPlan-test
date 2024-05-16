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
        let startRoot: CGPoint
        let endRoot: CGPoint
        
        init(
            p0 start: CGPoint,
            p1 end: CGPoint,
            rootPosition0 root0: CGPoint,
            rootPosition1 root1: CGPoint
        ) {
            self.start = start
            self.end = end
            self.startRoot = root0
            self.endRoot = root1
            
            super.init()
            
            self.draw()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func draw() {
            let shape = self.createShapeNode(
                from: self.createPath(from: self.start, to: self.end)
            )
            shape.lineWidth = Preference.shared.dimensionWidth
            shape.strokeColor = Preference.shared.dimensionColor
            
            let dashPattern: [CGFloat] = [
                Preference.shared.dimensionDashWidth,
                Preference.shared.dimensionDashSpan
            ]
            
            let start = self.createShapeNode(
                from: self.createPath(from: self.startRoot, to: self.start)
                    .copy(dashingWithPhase: 1, lengths: dashPattern)
            )
            start.lineWidth = Preference.shared.dimensionWidth
            start.strokeColor = Preference.shared.dimensionColor

            let end = self.createShapeNode(
                from: self.createPath(from: self.endRoot, to: self.end)
                    .copy(dashingWithPhase: 1, lengths: dashPattern)
            )
            end.lineWidth = Preference.shared.dimensionWidth
            end.strokeColor = Preference.shared.dimensionColor
            
            let center = (self.start + self.end) / 2
            let length = Int(round((self.end - self.start).length()))
            
            let labelAnchor = SKNode()
            labelAnchor.position = center
            labelAnchor.zRotation = self.start.angle(to: self.end)

            let label = SKLabelNode(fontNamed: Preference.shared.fontName)
            label.text = length.description
            label.fontColor = Preference.shared.fontColor
            label.fontSize = Preference.shared.fontSize
            label.position = CGPoint(x: 0, y: 50)
            labelAnchor.addChild(label)

            self.zPosition = self.priority
            
            self.addChild(shape)
            self.addChild(start)
            self.addChild(end)
            self.addChild(labelAnchor)
        }
    }

}
