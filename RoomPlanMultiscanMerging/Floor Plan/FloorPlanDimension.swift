//
//  FloorPlanDimension.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/04/25.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit

class FloorPlanDimension: SKNode {
    private let _dimensions: simd_float3
    private let _drawHeight: Bool
    
    private var _halfLength: CGFloat {
        return CGFloat(self._dimensions.x) * FloorPlanPreference.shared.scalingFactor / 2
    }
    var scaledHalfLength: CGFloat {
        self._halfLength
    }
    
    private var _startPoint: CGPoint {
        return CGPoint(x: -self._halfLength, y: 0)
    }
    
    private var _endPoint: CGPoint {
        return CGPoint(x: self._halfLength, y: 0)
    }
    
    var length: Float {
        self._dimensions.x
    }
    
    var height: Float {
        self._dimensions.y
    }
    
    init(
        dimensions: simd_float3,
        withHeight drawHeight: Bool
    ) {
        self._dimensions = dimensions
        self._drawHeight = drawHeight
        
        super.init()
        
        self.drawDimension()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawDimension() {
        let path = self.createPath(
            from: self._startPoint,
            to: self._endPoint
        )
        let shape = self.createShapeNode(from: path)
        shape.lineWidth = FloorPlanPreference.shared.dimensionWidth
        shape.strokeColor = FloorPlanPreference.shared.dimensionColor

        let start = SKShapeNode(circleOfRadius: FloorPlanPreference.shared.dimensionWidth * 5)
        start.fillColor = FloorPlanPreference.shared.dimensionColor
        start.position = self._startPoint

        let end = SKShapeNode(circleOfRadius: FloorPlanPreference.shared.dimensionWidth * 5)
        end.fillColor = FloorPlanPreference.shared.dimensionColor
        end.position = self._endPoint
        
        self.zPosition = FloorPlanPreference.shared.zDimension
        
        self.addChild(shape)
        self.addChild(start)
        self.addChild(end)
    }
}
