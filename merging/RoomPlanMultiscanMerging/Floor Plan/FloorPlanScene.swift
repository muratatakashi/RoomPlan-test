//
//  FloorPlanScene.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 10/03/2023.
//

import RoomPlan
import SpriteKit

class FloorPlanScene: SKScene {
    
    private let _room: CapturedRoom
    
    private var _surfaces: [CapturedRoom.Surface] {
        self._room.doors
        + self._room.openings
        + self._room.walls
        + self._room.windows
    }
    
    private var _objects: [CapturedRoom.Object] {
        self._room.objects
    }
    
    private var _rootNode: SKNode = SKNode()
    
    private var _surfaceDimensions: SurfaceDimensions?
   
    struct CameraProperty {
        var scale: CGFloat = .init()
        var position: CGPoint = .init()
    }
    private var _prevCameraProperty = CameraProperty()

    init(capturedRoom: CapturedRoom) {
        self._room = capturedRoom
        
        super.init(size: CGSize(width: 1500, height: 1500))
        
        self.scaleMode = .aspectFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.backgroundColor = FloorPlanPreference.shared.bgColor
        self.addChild(self._rootNode)
        
        self.addCamera()
        self.drawSurfaces()
//        drawObjects()
        self.resetCamera()
        self.drawSurfaceDimensions()
        // カメラ位置を再調整
        self.fixCameraPosition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        let panGestureRecognizer = UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(panGestureAction(_:)))
        view.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer()
        pinchGestureRecognizer.addTarget(self, action: #selector(pinchGestureAction(_:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
    }

    private func drawSurfaces() {
        for surface in self._surfaces {
            let surfaceNode = FloorPlanSurface(capturedSurface: surface)
            self._rootNode.addChild(surfaceNode)
        }
    }
    
    private func drawSurfaceDimensions() {
        self._surfaceDimensions = SurfaceDimensions(
            scene: self,
            root: self._rootNode
        )
        self._surfaceDimensions?.draw()
    }
    
    private func drawObjects() {
        for object in self._objects {
            let objectNode = FloorPlanObject(capturedObject: object)
            self._rootNode.addChild(objectNode)
        }
    }

    private func addCamera() {
        let cameraNode = SKCameraNode()
        self.addChild(cameraNode)
        
        self.camera = cameraNode
    }
    
    // 回転角とスケールの初期設定
    private func resetCamera() {
        // 回転
        self.fixCameraRotation()
        // 位置
        self.fixCameraPosition()
        
//        let rect = self._rootNode.calculateAccumulatedFrame()
//        let bbox = SKShapeNode(rect: rect)
//        bbox.fillColor = UIColor.red.withAlphaComponent(0.5)
//        self.addChild(bbox)
    }
    
    private func fixCameraRotation() {
        self._rootNode.zRotation = 0
        
        // 一番長いsurfaceを探す
        guard let surface = self._surfaces.sorted(by: {
            $0.dimensions.x < $1.dimensions.x
        }).last else {
            return
        }
        
        // 図形化
        let floorPlanSurface = FloorPlanSurface(capturedSurface: surface)
        
        // 回転角
        let zRot = floorPlanSurface.zRotation
        
        // rootをその分逆に回す
        self._rootNode.zRotation = -zRot
        
        // iPhoneは縦向き
        if UIDevice.current.userInterfaceIdiom == .phone {
            self._rootNode.zRotation -= (.pi / 2)
        }
    }
    
    private func fixCameraPosition() {
        guard let camera = self.camera else { return }

        let targetFrame = self._rootNode.calculateAccumulatedFrame()
        let center = CGPoint(
            x: targetFrame.origin.x + (targetFrame.width / 2),
            y: targetFrame.origin.y + (targetFrame.height / 2)
        )
        camera.position = center
        
        // ついでにviewのサイズもノードが収まるサイズに
        self.size = targetFrame.size
    }

    @objc private func panGestureAction(_ sender: UIPanGestureRecognizer) {
        guard let camera = self.camera else { return }
        
        if sender.state == .began {
            self._prevCameraProperty.position = camera.position
        }
        
        // 移動量は適当...
        let translationScale = camera.xScale * FloorPlanPreference.shared.scalingFactor * 0.03
        let panTranslation = sender.translation(in: self.view)
        let newCameraPosition = CGPoint(
            x: self._prevCameraProperty.position.x + panTranslation.x * -translationScale,
            y: self._prevCameraProperty.position.y + panTranslation.y * translationScale
        )
        
        camera.position = newCameraPosition
    }
    

    @objc private func pinchGestureAction(_ sender: UIPinchGestureRecognizer) {
        guard let camera = self.camera else { return }
        
        if sender.state == .began {
            self._prevCameraProperty.scale = camera.xScale
        }
        
        camera.setScale(self._prevCameraProperty.scale * 1 / sender.scale)
    }
    
}
