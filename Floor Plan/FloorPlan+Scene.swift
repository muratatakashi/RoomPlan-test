//
//  FloorPlan+Scene.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 10/03/2023.
//

import RoomPlan
import SpriteKit

extension FloorPlan {
    final class Scene: SKScene {
        
        private let _structure: CapturedStructure
        
        private var _surfaces: [CapturedRoom.Surface] {
            self._structure.doors
            + self._structure.openings
            + self._structure.walls
            + self._structure.windows
        }
        
        private var _objects: [CapturedRoom.Object] {
            self._structure.objects
        }
        
        private var _rootNode: SKNode = SKNode()
        
        private var _surfaceDimensions: SurfaceDimensions?
       
        struct CameraProperty {
            var scale: CGFloat = .init()
            var position: CGPoint = .init()
        }
        private var _prevCameraProperty = CameraProperty()
        
        private let _defaultViewSize = CGSize(width: 1000, height: 1000)

        init(capturedStructure: CapturedStructure) {
            self._structure = capturedStructure
            
            super.init(size: self._defaultViewSize)

            self.setupScene()
            


            // debug
            self._rootNode.children.forEach {
                guard let surfaceNode = $0 as? FloorPlan.Surface,
                      surfaceNode.surface.category == .wall
                else { return }
                
                let node1 = SKShapeNode(circleOfRadius: 100)
                node1.fillColor = .blue
                node1.position = surfaceNode.world.start
                
                let node2 = SKShapeNode(circleOfRadius: 100)
                node2.fillColor = .green
                node2.position = surfaceNode.world.end
                
                self._rootNode.addChild(node1)
                self._rootNode.addChild(node2)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // gesture
        override func didMove(to view: SKView) {
            let panGestureRecognizer = UIPanGestureRecognizer()
            panGestureRecognizer.addTarget(self, action: #selector(panGestureAction(_:)))
            view.addGestureRecognizer(panGestureRecognizer)
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer()
            pinchGestureRecognizer.addTarget(self, action: #selector(pinchGestureAction(_:)))
            view.addGestureRecognizer(pinchGestureRecognizer)
        }
        
        private func setupScene() {
            self.scaleMode = .aspectFill
            self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.backgroundColor = Preference.shared.bgColor
            self.addChild(self._rootNode)
            
            // カメラ
            self.setupCamera()
            
            // ロード
            self.loadScene()
        }

        private func setupCamera() {
            let cameraNode = SKCameraNode()
            self.addChild(cameraNode)
            self.camera = cameraNode
        }
        
        private func loadScene() {
            // 1回描画して傾きの補正とビューのスケールを求める
            self.drawSurfaces()
            self.setupScale()
            
            // 向きを調整
            self.fixZRotation()

            // 各図形の座標系をローカルからワールドに変換
            self.convertLocalToWorld()
            
            // ビューサイズ設定
            self.setupViewSize()
            
            // カメラを中心に
            self.moveCameraToCenter()
        }
        
        private func setupScale() {
            Preference.shared.scalingFactor = 1

            // フレームサイズを取得
            let targetFrame = self._rootNode.calculateAccumulatedFrame()
            
            // スケールを計算
            let length = max(targetFrame.width, targetFrame.height)
            
            Preference.shared.scalingFactor = length / self._defaultViewSize.width
        }
        
        private func fixZRotation() {
            self._rootNode.zRotation = 0
            
            // 一番長いsurfaceを探す
            guard let surface = self._surfaces.sorted(by: {
                $0.dimensions.x < $1.dimensions.x
            }).last else {
                return
            }
            
            // 図形化(とりあえず壁。なんでもいい)
            let wall = FloorPlan.Wall(capturedSurface: surface)
            
            // 回転角
            let zRot = wall.zRotation
            
            // rootをその分逆に回す
            self._rootNode.zRotation = -zRot
            
            // iPhoneは縦向き
            if UIDevice.current.userInterfaceIdiom == .phone {
                self._rootNode.zRotation -= (.pi / 2)
            }
        }
        
        private func convertLocalToWorld() {
            var nodes = [FloorPlan.Surface]()
            
            // 全ノードを回転後のワールド座標で置き換える
            self._rootNode.children.forEach {
                guard let surfaceNode = $0 as? FloorPlan.Surface else {
                    return
                }
                
                switch surfaceNode.surface.category {
                case .door:
                    nodes.append(
                        FloorPlan.Door(
                            capturedSurface: surfaceNode.surface,
                            from: surfaceNode.world.start,
                            to: surfaceNode.world.end
                        )
                    )
                case .opening:
                    nodes.append(
                        FloorPlan.Opening(
                            capturedSurface: surfaceNode.surface,
                            from: surfaceNode.world.start,
                            to: surfaceNode.world.end
                        )
                    )
                case .window:
                    nodes.append(
                        FloorPlan.Window(
                            capturedSurface: surfaceNode.surface,
                            from: surfaceNode.world.start,
                            to: surfaceNode.world.end
                        )
                    )
                default:
                    nodes.append(
                        FloorPlan.Wall(
                            capturedSurface: surfaceNode.surface,
                            from: surfaceNode.world.start,
                            to: surfaceNode.world.end
                        )
                    )
                }
                surfaceNode.removeFromParent()
            }
            
            self._rootNode.zRotation = 0
            self._rootNode.position = .zero
            
            nodes.forEach {
                self._rootNode.addChild($0)
            }
        }
        
        private func setupViewSize() {
            let targetFrame = self._rootNode.calculateAccumulatedFrame()
            
            if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                let aspectRatio = window.screen.bounds.width / window.screen.bounds.height
                let length = max(targetFrame.width, targetFrame.height)
                
                if 1 < aspectRatio {
                    // 横長
                    self.size = CGSize(
                        width: length * aspectRatio,
                        height: length
                    )
                } else {
                    // 縦長
                    self.size = CGSize(
                        width: length,
                        height: length / aspectRatio
                    )
                }
            } else {
                // こっちはまず来ないはず
                let scale = UIDevice.current.userInterfaceIdiom == .pad ? 1.2 : 1.5
                self.size = CGSize(
                    width: targetFrame.width * scale,
                    height: targetFrame.height * scale
                )
            }
        }
        
        private func moveCameraToCenter() {
            guard let camera = self.camera else { return }

            let targetFrame = self._rootNode.calculateAccumulatedFrame()
            let center = CGPoint(
                x: targetFrame.midX,
                y: targetFrame.midY
            )
            camera.position = center
            
    //        let shape = SKShapeNode(rect: targetFrame)
    //        shape.lineWidth = 100
    //        shape.strokeColor = .red
    //        self.addChild(shape)
        }
        
        private func drawSurfaces() {
            self._surfaces.forEach {
                switch $0.category {
                case .door:
                    self._rootNode.addChild(FloorPlan.Door(capturedSurface: $0))
                case .opening:
                    self._rootNode.addChild(FloorPlan.Opening(capturedSurface: $0))
                case .window:
                    self._rootNode.addChild(FloorPlan.Window(capturedSurface: $0))
                default:
                    self._rootNode.addChild(FloorPlan.Wall(capturedSurface: $0))
                }
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
                let objectNode = FloorPlan.Object(capturedObject: object)
                self._rootNode.addChild(objectNode)
            }
        }


        @objc private func panGestureAction(_ sender: UIPanGestureRecognizer) {
            guard let camera = self.camera else { return }
            
            if sender.state == .began {
                self._prevCameraProperty.position = camera.position
            }
            
            // 移動量は適当...
            let translationScale = camera.xScale * Preference.shared.scalingFactor * 2
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

}
