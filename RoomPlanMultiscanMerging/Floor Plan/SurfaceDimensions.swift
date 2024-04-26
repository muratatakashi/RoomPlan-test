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

            var position = CGPoint(x: 0, y: 0)
            
            let offset = CGFloat(100 * step)

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
    
    struct DimensionProperty {
        let position: Position
        let surface: FloorPlanSurface
        let dimension: FloorPlanDimension
        let step: Int
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
                
                let label = SKLabelNode(text: "\(index)")
                label.fontName = FloorPlanPreference.shared.fontName
                label.fontColor = FloorPlanPreference.shared.fontColor
                label.fontSize = FloorPlanPreference.shared.fontSize
                dimension.addChild(label)
                
                index += 1
                
                let property = DimensionProperty(
                    position: position,
                    surface: surface,
                    dimension: dimension,
                    step: 0
                )
                
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
        
        self.dimensions[.left]?.forEach {
            let p0 = $0.dimension.position
            print(p0)
            let p1 = $0.surface.convert(p0, to: self.root)
            print(p1)
            let p2 = self.root.convert(p1, to: self.scene)
            print(p2)
        }
    }
    
    private func setupDimensionSteps(to props: [DimensionProperty]) {
        for i in 0..<(props.count-1) {
            var d1 = props[i]

            for j in (i+1)..<props.count {
                var d2 = props[j]
                
                let p1 = self.root.convert(
                    d1.surface.convert(d1.dimension.position, to: self.root),
                    to: self.scene
                )
            }
        }
    }
    
    func draw() {
        //作り終わったら描画
        self.dimensions.forEach { position, props in
            props.forEach {
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
