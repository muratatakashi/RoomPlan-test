//
//  FloorPlanExtensions.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/04/25.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit

extension SKNode {
    func createPath(from start: CGPoint, to end: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        return path
    }
    
    func createShapeNode(from path: CGPath) -> SKShapeNode {
        let shapeNode = SKShapeNode(path: path)
        shapeNode.strokeColor = FloorPlanPreference.shared.surfaceColor
        shapeNode.lineWidth = FloorPlanPreference.shared.surfaceWith
        return shapeNode
    }
    
    func createRect(
        from start: CGPoint,
        to end: CGPoint,
        width: CGFloat // 太さ
    ) -> CGRect {
        return CGRect(
            x: start.x,
            y: start.y - (width / 2),
            width: end.x - start.x,
            height: width
        )
    }
    
    func createShapeNode(from rect: CGRect) -> SKShapeNode {
        let shapeNode = SKShapeNode(rect: rect)
        shapeNode.strokeColor = FloorPlanPreference.shared.surfaceColor
        shapeNode.fillColor = FloorPlanPreference.shared.bgColor
        shapeNode.lineWidth = FloorPlanPreference.shared.rectLineWidth
        return shapeNode
    }
}

extension CGFloat {
    var degree: CGFloat {
        self * 180 / .pi
    }
    
    var radian: CGFloat {
        self * .pi / 180
    }
}
