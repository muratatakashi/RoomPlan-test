//
//  SurfaceDimensions.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/04/25.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit
import RoomPlan

final class SurfaceDimensions {
    enum Position {
        case top
        case bottom
        case left
        case right
        
        func dimensionPosition(scene: SKScene, root: SKNode, surface: SKNode, step: Int) -> CGPoint {
            let frame = root.calculateAccumulatedFrame()
            
            let surfacePosition = scene.convert(surface.position, from: root)
//            let p = surface.convertWorld(position: surface.position)

            let offset = CGFloat(50 * step)

            var position = CGPoint(x: 0, y: 0)

            switch self {
            case .top:
                let yOffset = (frame.maxY - surfacePosition.y) + offset
                position.y = -yOffset
            case .bottom:
                let yOffset = (surfacePosition.y - frame.minY) + offset
                position.y = -yOffset
            case .left:
                let xOffset = (surfacePosition.x - frame.minX) + offset
                position.y = -xOffset
            case .right:
                let xOffset = (frame.maxX - surfacePosition.x) + offset
                position.y = -xOffset
            }
            
            return position
        }
    }
    
    class DimensionProperty {
        let position: Position
        let surface: FloorPlanSurface
        let dimension: FloorPlanDimension
        var step: Int
        var visible: Bool = true
        
        var index: Int? = nil
        
        init(position: Position, surface: FloorPlanSurface, dimension: FloorPlanDimension, step: Int, visible: Bool) {
            self.position = position
            self.surface = surface
            self.dimension = dimension
            self.step = step
            self.visible = visible
        }
        
        func dimensionRange(
            scene: SKScene,
            root: SKNode
        ) -> [CGPoint] {
            let p = self.dimension.convertWorld(position: self.dimension.position)
            
            switch position {
            case .top, .bottom:
                return [
                    CGPoint(x: p.x - self.dimension.scaledHalfLength, y: 0),
                    CGPoint(x: p.x + self.dimension.scaledHalfLength, y: 0),
                ]
            case .left, .right:
                return [
                    CGPoint(x: 0, y: p.y - self.dimension.scaledHalfLength),
                    CGPoint(x: 0, y: p.y + self.dimension.scaledHalfLength),
                ]
            }
        }
        
        func contains(
            scene: SKScene,
            root: SKNode,
            props: DimensionProperty
        ) -> Bool {
            let range0 = self.dimensionRange(scene: scene, root: root)
            let range1 = props.dimensionRange(scene: scene, root: root)
            
            guard self.position == props.position else {
                return false
            }
            
            return switch self.position {
            case .top, .bottom:
                range0[0].x <= range1[0].x && range1[1].x <= range0[1].x
            case .left, .right:
                range0[0].y <= range1[0].y && range1[1].y <= range0[1].y
            }
        }
        
        func overlap(
            scene: SKScene,
            root: SKNode,
            props: DimensionProperty
        ) -> Bool {
            let range0 = self.dimensionRange(scene: scene, root: root)
            let range1 = props.dimensionRange(scene: scene, root: root)
            
            guard self.position == props.position else {
                return false
            }

            return switch self.position {
            case .top, .bottom:
                range0[0].x <= range1[0].x && range1[0].x <= range0[1].x
                || range0[0].x <= range1[1].x && range1[1].x <= range0[1].x
//                let center0 = (range0[0].x + range0[1].x) / 2
//                let center1 = (range1[0].x + range1[1].x) / 2
//                let length = abs(center0 - center1)
//                return Float(length) < (self.dimension.length + props.dimension.length) / 2
            case .left, .right:
                range0[0].y <= range1[0].y && range1[0].y <= range0[1].y
                || range0[0].y <= range1[1].y && range1[1].y <= range0[1].y
//                let center0 = (range0[0].y + range0[1].y) / 2
//                let center1 = (range1[0].y + range1[1].y) / 2
//                let length = abs(center0 - center1)
//                return Float(length) < (self.dimension.length + props.dimension.length) / 2
            }
        }
        
        func equal(
            scene: SKScene,
            root: SKNode,
            props: DimensionProperty
        ) -> Bool {
            let range0 = self.dimensionRange(scene: scene, root: root)
            let range1 = props.dimensionRange(scene: scene, root: root)
            
            guard self.position == props.position else {
                return false
            }
            guard Int(self.dimension.length * 10) == Int(props.dimension.length * 10) else {
                return false
            }
            
            // cm単位で比較
            return switch self.position {
            case .top, .bottom:
                Int(range0[0].x * 10) == Int(range1[0].x * 10) && Int(range0[1].x * 10) == Int(range1[1].x * 10)
            case .left, .right:
                Int(range0[0].y * 10) == Int(range1[0].y * 10) && Int(range0[1].y * 10) == Int(range1[1].y * 10)
            }
        }
    }
    
    weak private(set) var scene: SKScene!
    weak private(set) var root: SKNode!
    
    private let _THRESHOLD: CGFloat = 2
    
    init(scene: SKScene, root: SKNode) {
        self.scene = scene
        self.root = root
        self.load()
    }

    private(set) var surfaces: [Position:[FloorPlanSurface]] = [:]
    private(set) var dimensions: [Position:[DimensionProperty]] = [:]
    
    private func load() {
        self.assignSurfaces()
        self.setupDimensions()
    }
    
    private func assignSurfaces() {
        // 上下左右に振り分け
        self.root.children.forEach {
            guard let surface = $0 as? FloorPlanSurface,
                  surface.surface.category == .wall // 一旦壁だけ
            else {
                return
            }
            
            let rad = self.root.zRotation + surface.zRotation
            var deg = rad.degree
            while deg < 0 {
                deg += 360
            }

            if abs(deg - 0) < 2 {
                // 下側
                if self.surfaces[.bottom] == nil {
                    self.surfaces[.bottom] = []
                }
                self.surfaces[.bottom]?.append(surface)
            } else if abs(deg - 180) < self._THRESHOLD {
                // 上側
                if self.surfaces[.top] == nil {
                    self.surfaces[.top] = []
                }
                self.surfaces[.top]?.append(surface)
            } else if abs(deg - 90) < self._THRESHOLD {
                // 右側
                if self.surfaces[.right] == nil {
                    self.surfaces[.right] = []
                }
                self.surfaces[.right]?.append(surface)
            } else if abs(deg - 270) < self._THRESHOLD {
                // 左側
                if self.surfaces[.left] == nil {
                    self.surfaces[.left] = []
                }
                self.surfaces[.left]?.append(surface)
            }
        }
    }
    
    
    private func setupDimensions() {
        self.clear()
        
        var index: Int = 0
        
        self.surfaces.forEach { position, surfaces in
            if self.dimensions[position] == nil {
                self.dimensions[position] = []
            }
            surfaces.forEach { surface in
                let step: Int = 0
                let dimension = FloorPlanDimension(
                    dimensions: surface.surface.dimensions,
                    withHeight: false
                )
                
                // 閾値(一旦適当)
                guard 1 <=  dimension.length else { return }
                
//                surface.addChild(dimension)
                dimension.position = position.dimensionPosition(
                    scene: self.scene,
                    root: self.root,
                    surface: surface,
                    step: step
                )
                
                
                let label = SKLabelNode(text: "\(Int (surface.surface.dimensions.x * 1000))")
                label.fontName = FloorPlanPreference.shared.fontName
                label.fontColor = FloorPlanPreference.shared.fontColor
                label.fontSize = FloorPlanPreference.shared.fontSize
                dimension.addChild(label)
                
                let property = DimensionProperty(
                    position: position,
                    surface: surface,
                    dimension: dimension,
                    step: 0,
                    visible: true
                )
                property.index = index

                index += 1

                self.dimensions[position]?.append(property)
            }
        }
        
        self.setupDimmensionSteps()
    }
    
    // 寸法の階層を決める
    private func setupDimmensionSteps() {
        // サイズ順に並び替え
        self.dimensions[.top]?.sort(by: {$0.dimension.length < $1.dimension.length})
        self.dimensions[.bottom]?.sort(by: {$0.dimension.length < $1.dimension.length})
        self.dimensions[.left]?.sort(by: {$0.dimension.length < $1.dimension.length})
        self.dimensions[.right]?.sort(by: {$0.dimension.length < $1.dimension.length})
        
        self.dimensions.forEach { _, properties in
            self.setupDimensionSteps(to: properties)
        }
    }
    
    private func setupDimensionSteps(to props: [DimensionProperty]) {
        guard !props.isEmpty else { return }
        
        var step: Int = 0
        props.forEach {
            if $0.position == .left {
                let range = $0.dimensionRange(scene: self.scene, root: self.root)
                print($0.index!, range[0].y, range[1].y, $0.dimension.length)
            }
            
            $0.step = step
            step += 1
        }
        
        for i in 0..<(props.count-1) {
            let d1 = props[i]

            for j in (i+1)..<props.count {
                guard d1.visible else {
                    break
                }
                
                let d2 = props[j]
                
                if d2.equal(scene: self.scene, root: self.root, props: d1) {
                    d1.visible = false
                } else if d2.overlap(scene: self.scene, root: self.root, props: d1) {
//                    d1.visible = false
                }

                
//                if d2.overlap(scene: self.scene, root: self.root, props: d1)
//                    || d2.equal(scene: self.scene, root: self.root, props: d1)
//                {
//                    // 片側だけ重なってたらor等しかったらd1(小さい方)を除外
//                    d1.visible = false
//                } 
//                else if d2.contains(scene: self.scene, root: self.root, props: d1) {
//                    // d2の内側に入ってたらd2を上の階層に移動
//                    d2.step = d1.step + 1
//                }
            }
        }
        
        // 座標をstepに応じて更新
        props.forEach {
            $0.dimension.position = $0.position.dimensionPosition(
                scene: self.scene,
                root: self.root,
                surface: $0.surface,
                step: $0.step
            )
        }
    }
    
    func draw() {
        //作り終わったら描画
        self.dimensions.forEach { position, props in
            props.forEach {
                guard $0.visible else {
                    return
                }
                $0.surface.addChild($0.dimension)
            }
        }
    }
    
    func setVisible(enable: Bool) {
        self.dimensions.forEach { position, dimensions in
            dimensions.forEach {
                $0.dimension.isHidden = !enable
            }
        }
    }
    
    func clear() {
        self.dimensions.forEach { position, dimensions in
            dimensions.forEach {
                $0.dimension.removeFromParent()
            }
        }
        self.dimensions = [:]
    }
}
