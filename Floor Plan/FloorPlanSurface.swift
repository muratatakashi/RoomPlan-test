//
//  FloorPlanSurface.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 12/03/2023.
//

import SpriteKit
import RoomPlan

class FloorPlanSurface: SKNode {
    
    let surface: CapturedRoom.Surface
    
    // MARK: - Computed properties
    
    private var _halfLength: CGFloat {
        return CGFloat(self.surface.dimensions.x) * FloorPlanPreference.shared.m2mm / 2
    }
    
    private var _startPoint: CGPoint = CGPointZero
    private var _endPoint: CGPoint = CGPointZero
    
    private var _doorEndPoint: CGPoint {
        return self._endPoint.rotateAround(point: self._startPoint, by: 0.25 * .pi)
    }
    
    var worldPositions: [CGPoint] {
        [
            self.convertWorld(position: self._startPoint),
            self.convertWorld(position: self._endPoint)
        ]
    }
    
    // MARK: - Init
    
    init(
        capturedSurface surface: CapturedRoom.Surface
    ) {
        self.surface = surface
        
        super.init()
        
        // Set the surface's position using the transform matrix
        let surfacePositionX = -CGFloat(surface.transform.position.x) * FloorPlanPreference.shared.m2mm
        let surfacePositionY = CGFloat(surface.transform.position.z) * FloorPlanPreference.shared.m2mm
        self.position = CGPoint(x: surfacePositionX, y: surfacePositionY)
        
        // Set the surface's zRotation using the transform matrix
        self.zRotation = -CGFloat(surface.transform.eulerAngles.z - surface.transform.eulerAngles.y)
        
        self._startPoint = CGPoint(x: -self._halfLength, y: 0)
        self._endPoint = CGPoint(x: self._halfLength, y: 0)
        
        // Draw the right surface
        switch surface.category {
        case .door:
            self.drawDoor()
        case .opening:
            self.drawOpening()
        case .wall:
            self.drawWall()
        case .window:
            self.drawWindow()
        default:
            self.drawWall()
        }
    }
    
    init(
        capturedSurface surface: CapturedRoom.Surface,
        from startPoint: CGPoint,
        to endPoint: CGPoint
    ) {
        self.surface = surface
        
        super.init()
        
        self._startPoint = startPoint
        self._endPoint = endPoint
        
        // Draw the right surface
        switch surface.category {
        case .door:
            self.drawDoor()
        case .opening:
            self.drawOpening()
        case .wall:
            self.drawWall()
        case .window:
            self.drawWindow()
        default:
            self.drawWall()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Draw

    private func drawDoor() {
        let hideWallPath = self.createPath(from: self._startPoint, to: self._endPoint)
        let doorPath = self.createPath(from: self._startPoint, to: self._endPoint)
//        let doorPath = self.createPath(from: self._startPoint, to: self._doorEndPoint)

        // Hide the wall underneath the door
        let hideWallShape = self.createShapeNode(from: hideWallPath)
        hideWallShape.strokeColor = FloorPlanPreference.shared.bgColor
        hideWallShape.lineWidth = FloorPlanPreference.shared.hideSurfaceWith
        hideWallShape.zPosition = FloorPlanPreference.shared.zHideSurface
        
        // The door itself
        let doorShape = self.createShapeNode(from: doorPath)
        doorShape.strokeColor = .orange
        doorShape.lineCap = .square
        doorShape.zPosition = FloorPlanPreference.shared.zDoor
        
//        // The door's arc
//        let doorArcPath = CGMutablePath()
//        doorArcPath.addArc(
//            center: self._startPoint,
//            radius: self._halfLength * 2,
//            startAngle: 0.25 * .pi,
//            endAngle: 0,
//            clockwise: true
//        )
        
//        // Create a dashed path
//        let dashPattern: [CGFloat] = [
//            FloorPlanPreference.shared.doorDashWidth,
//            FloorPlanPreference.shared.doorDashSpan
//        ]
//        let dashedArcPath = doorArcPath.copy(dashingWithPhase: 1, lengths: dashPattern)
//
//        let doorArcShape = self.createShapeNode(from: dashedArcPath)
//        doorArcShape.lineWidth = FloorPlanPreference.shared.doorArcWidth
//        doorArcShape.zPosition = FloorPlanPreference.shared.zDoorArc
        
        self.addChild(hideWallShape)
        self.addChild(doorShape)
//        self.addChild(doorArcShape)
    }
    
    private func drawOpening() {
        let openingPath = self.createPath(from: self._startPoint, to: self._endPoint)
        
        // Hide the wall underneath the opening
        let hideWallShape = self.createShapeNode(from: openingPath)
        hideWallShape.strokeColor = .blue// FloorPlanPreference.shared.bgColor
        hideWallShape.lineWidth = FloorPlanPreference.shared.hideSurfaceWith
        hideWallShape.zPosition = FloorPlanPreference.shared.zHideSurface
        
        self.addChild(hideWallShape)
    }
    
    private func drawWall() {
        let wallPath = self.createPath(from: self._startPoint, to: self._endPoint)
        let wallShape = self.createShapeNode(from: wallPath)
        wallShape.lineCap = .square

//        let wallRect = createRect(
//            from: self._startPoint,
//            to: self._endPoint,
//            width: FloorPlanPreference.shared.surfaceWith
//        )
//        let wallShape = self.createShapeNode(from: wallRect)
        
//        if self._showDimension {
//            let dimensionPath = self.createPath(
//                from: CGPoint(x: self._startPoint.x, y: -100),
//                to: CGPoint(x: self._endPoint.x, y: -100)
//            )
//            let dimmensionShape = self.createShapeNode(from: dimensionPath)
//            dimmensionShape.lineWidth = 3
//            dimmensionShape.lineCap = .square
//            wallShape.addChild(dimmensionShape)
//        }

        self.addChild(wallShape)
    }
    
    private func drawWindow() {
        let windowPath = self.createPath(from: self._startPoint, to: self._endPoint)
        
        // Hide the wall underneath the window
        let hideWallShape = self.createShapeNode(from: windowPath)
        hideWallShape.strokeColor = FloorPlanPreference.shared.bgColor
        hideWallShape.lineWidth = FloorPlanPreference.shared.hideSurfaceWith
        hideWallShape.zPosition = FloorPlanPreference.shared.zHideSurface
        
        // The window itself
//        let windowShape = self.createShapeNode(from: windowPath)
//        windowShape.lineWidth = FloorPlanPreference.shared.windowWidth
        let windowRect = self.createRect(
            from: self._startPoint,
            to: self._endPoint,
            width: FloorPlanPreference.shared.windowRectWidth
        )
        let windowShape = self.createShapeNode(from: windowRect)

        windowShape.zPosition = FloorPlanPreference.shared.zWindow

        self.addChild(hideWallShape)
        self.addChild(windowShape)
    }
}
