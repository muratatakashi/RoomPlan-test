//
//  SurfaceDimensions.swift
//  FloorPlan+DimensionDetector
//
//  Created by Takashi Murata on 2024/04/25.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit
import RoomPlan

extension FloorPlan {
    final class DimensionDetector {
        enum Position: CaseIterable {
            case top
            case bottom
            case left
            case right
        }
        
        private var _dimensionMap: [Position:[Pillar]] = [:]
        
        private(set) var dimensions: [Dimension] = []
        
        func load(root: SKNode, pillars: [Pillar]) {
            self.loadDimensionMap(root: root, pillars: pillars)
            self.loadDimensions(root: root)
        }
        
        private func loadDimensionMap(root: SKNode, pillars: [Pillar]) {
            self._dimensionMap.removeAll()
            Position.allCases.forEach {
                self._dimensionMap[$0] = []
            }
            
            let frame = root.calculateAccumulatedFrame()
            
            // 上下左右に振り分け
            pillars.forEach { pillar in
                if pillar.position.x < frame.midX {
                    // 左
                    if let index = self._dimensionMap[.left]?.firstIndex(where: {$0.position.y == pillar.position.y}) {
                        // yが同じ場合はより左によっているものを採用
                        if let oldPillar = self._dimensionMap[.left]?[index],
                           pillar.position.x < oldPillar.position.x
                        {
                            self._dimensionMap[.left]?[index] = pillar
                        }
                    } else {
                        // ないなら採用
                        self._dimensionMap[.left]?.append(pillar)
                    }
                } else {
                    // 右
                    if let index = self._dimensionMap[.right]?.firstIndex(where: {$0.position.y == pillar.position.y}) {
                        // yが同じ場合はより右によっているものを採用
                        if let oldPillar = self._dimensionMap[.right]?[index],
                           oldPillar.position.x < pillar.position.x
                        {
                            self._dimensionMap[.right]?[index] = pillar
                        }
                    } else {
                        // ないなら採用
                        self._dimensionMap[.right]?.append(pillar)
                    }
                }
                
                if pillar.position.y < frame.midY {
                    // 上
                    if let index = self._dimensionMap[.top]?.firstIndex(where: {$0.position.x == pillar.position.x}) {
                        // xが同じ場合はより上によっているものを採用
                        if let oldPillar = self._dimensionMap[.top]?[index],
                           pillar.position.y < oldPillar.position.y
                        {
                            self._dimensionMap[.top]?[index] = pillar
                        }
                    } else {
                        // ないなら採用
                        self._dimensionMap[.top]?.append(pillar)
                    }
                } else {
                    // 下
                    if let index = self._dimensionMap[.bottom]?.firstIndex(where: {$0.position.x == pillar.position.x}) {
                        // xが同じ場合はより下によっているものを採用
                        if let oldPillar = self._dimensionMap[.bottom]?[index],
                           oldPillar.position.y < pillar.position.y
                        {
                            self._dimensionMap[.bottom]?[index] = pillar
                        }
                    } else {
                        // ないなら採用
                        self._dimensionMap[.bottom]?.append(pillar)
                    }
                }
            }
            
            // ソート
            self._dimensionMap[.left]?.sort(by: {$0.position.y < $1.position.y})
            self._dimensionMap[.right]?.sort(by: {$0.position.y < $1.position.y})
            self._dimensionMap[.top]?.sort(by: {$0.position.x < $1.position.x})
            self._dimensionMap[.bottom]?.sort(by: {$0.position.x < $1.position.x})
        }
        
        private func loadDimensions(root: SKNode) {
            self.dimensions.removeAll()
            
            let frame = root.calculateAccumulatedFrame()
            
            self._dimensionMap.forEach { position, pillars in
                
                for i in 0..<(pillars.count - 1) {
                    let p0 = pillars[i]
                    let p1 = pillars[i+1]
                    
                    switch position {
                    case .left:
                        self.dimensions.append(
                            Dimension(
                                from: CGPoint(x: frame.minX, y: p0.position.y),
                                to: CGPoint(x: frame.minX, y: p1.position.y)
                            )
                        )
                    case .right:
                        self.dimensions.append(
                            Dimension(
                                from: CGPoint(x: frame.maxX, y: p0.position.y),
                                to: CGPoint(x: frame.maxX, y: p1.position.y)
                            )
                        )
                    case .top:
                        self.dimensions.append(
                            Dimension(
                                from: CGPoint(x: p0.position.x, y: frame.minY),
                                to: CGPoint(x: p1.position.x, y: frame.minY)
                            )
                        )
                    case .bottom:
                        self.dimensions.append(
                            Dimension(
                                from: CGPoint(x: p0.position.x, y: frame.maxY),
                                to: CGPoint(x: p1.position.x, y: frame.maxY)
                            )
                        )
                    }
                }
            }
        }
    }
}
