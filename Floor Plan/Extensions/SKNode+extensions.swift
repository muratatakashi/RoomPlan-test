//
//  SKNode+extensions.swift
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
    
    func createShapeNode(
        from path: CGPath,
        strokeColor: UIColor = FloorPlan.Preference.shared.surfaceColor,
        fillColor: UIColor = FloorPlan.Preference.shared.surfaceColor,
        width: CGFloat = FloorPlan.Preference.shared.surfaceWidth
    ) -> SKShapeNode {
        let shapeNode = SKShapeNode(path: path)
        shapeNode.strokeColor = strokeColor
        shapeNode.lineWidth = width
        return shapeNode
    }
    
    private func createRect(
        from start: CGPoint,
        to end: CGPoint,
        width: CGFloat // 太さ
    ) -> CGRect {
        
        // 線の長さ
        let length = (end - start).length()
        
        // 横棒作る
        return CGRect(
            x: 0,
            y: 0,
            width: length,
            height: width
        )
    }
    
    func createBoxLineNode(
        from start: CGPoint,
        to end: CGPoint,
        width: CGFloat,
        lineWidth: CGFloat = FloorPlan.Preference.shared.rectLineWidth,
        strokeColor: UIColor = FloorPlan.Preference.shared.surfaceColor,
        fillColor: UIColor = FloorPlan.Preference.shared.bgColor
    ) -> SKShapeNode {
        let rect = self.createRect(from: start, to: end, width: width)
        let shapeNode = SKShapeNode(rectOf: rect.size)
        shapeNode.strokeColor = strokeColor
        shapeNode.fillColor = fillColor
        shapeNode.lineWidth = lineWidth
        
        // 中心
        let center = (start + end) / 2
        
        // 角度
        let angle = start.angle(to: end)

        shapeNode.position = center
        shapeNode.zRotation = angle
        
        return shapeNode
    }
    
    func convertWorld(position localPosition: CGPoint) -> CGPoint {
        guard let scene = self.scene else {
            return localPosition
        }
        return self.convert(localPosition, to: scene)
    }
}
