//
//  FloorPlan+Object.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 12/03/2023.
//

import SpriteKit
import RoomPlan

extension FloorPlan {
    final class Object: SKNode {
        
        private let object: CapturedRoom.Object
        
        // MARK: - Init
        
        init(capturedObject object: CapturedRoom.Object) {
            self.object = object
            
            super.init()
            
            // Set the object's position using the transform matrix
            let objectPositionX = -CGFloat(object.transform.position.x) * Preference.shared.m2mm
            let objectPositionY = CGFloat(object.transform.position.z) * Preference.shared.m2mm
            self.position = CGPoint(x: objectPositionX, y: objectPositionY)
            
            // Set the object's zRotation using the transform matrix
            self.zRotation = -CGFloat(object.transform.eulerAngles.z - object.transform.eulerAngles.y)
            
            drawObject()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Draw
        
        private func drawObject() {
            // Calculate the object's dimensions
            let objectWidth = CGFloat(object.dimensions.x) * Preference.shared.m2mm
            let objectHeight = CGFloat(object.dimensions.z) * Preference.shared.m2mm
            
            // Create the object's rectangle
            let objectRect = CGRect(
                x: -objectWidth / 2,
                y: -objectHeight / 2,
                width: objectWidth,
                height: objectHeight
            )
            
            // A shape to fill the object
            let objectShape = SKShapeNode(rect: objectRect)
            objectShape.strokeColor = .clear
            objectShape.fillColor = Preference.shared.surfaceColor
            objectShape.alpha = 0.3
            objectShape.zPosition = Preference.shared.zObject
            
            // And another shape for the outline
            let objectOutlineShape = SKShapeNode(rect: objectRect)
            objectOutlineShape.strokeColor = Preference.shared.surfaceColor
            objectOutlineShape.lineWidth = Preference.shared.objectOutlineWidth
            objectOutlineShape.lineJoin = .miter
            objectOutlineShape.zPosition = Preference.shared.zObjectOutline
                    
            // Add both shapes to the node
            addChild(objectShape)
            addChild(objectOutlineShape)
        }
        
    }
}
