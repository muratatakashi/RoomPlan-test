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
        
        private(set) var _simply: Bool = false
        
        func load(
            root: SKNode,
            pillars: [Pillar],
            simply: Bool
        ) {
            self._simply = simply
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
            
            let minLength: CGFloat = 300

            if self._simply {
                // ノイズは除外
                self.filteringDimensions(minLength: minLength)
            }
        }
        
        private func filteringDimensions(minLength threshold: CGFloat) {
            // 加減を下回る寸法は除外する
            
            self._dimensionMap.forEach { position, pillars in
                guard 3 < pillars.count else { return }
                
                var filteredPillars = [Pillar]()

                var basePillar = pillars[0]
                filteredPillars.append(basePillar)

                for i in 1..<(pillars.count-1) {
                    let length = self.length(with: position, from: basePillar.position, to: pillars[i].position)
                    if threshold <= length {
                        filteredPillars.append(pillars[i])
                        basePillar = pillars[i]
                    }
                }

                // 終点と1個前の長さが短かったら1個前は要らない
                if self.length(with: position, from: basePillar.position, to: pillars.last!.position) < threshold {
                    filteredPillars.removeLast()
                }
                
                // 最後は必要
                filteredPillars.append(pillars.last!)

                self._dimensionMap[position] = filteredPillars
            }
        }
        
        func length(with position: Position, from start: CGPoint, to end: CGPoint) -> CGFloat {
            switch position {
            case .left, .right:
                return abs(end.y - start.y)
            case .top, .bottom:
                return abs(end.x - start.x)
            }
        }
        
        private func loadDimensions(root: SKNode) {
            self.dimensions.removeAll()
            
            let frame = root.calculateAccumulatedFrame()
            
            let offset: CGFloat = 500
            let rootOffset: CGFloat = 50
            
            struct DimensionParam {
                let position: Position
                let p0: Pillar
                let p1: Pillar
                let offset: CGFloat
                let rootOffset: CGFloat
            }
            
            self._dimensionMap.forEach { position, pillars in
                
                var params = [DimensionParam]()
                
                for i in 0..<(pillars.count - 1) {
                    params.append(
                        DimensionParam(
                            position: position,
                            p0: pillars[i],
                            p1: pillars[i+1],
                            offset: offset,
                            rootOffset: rootOffset
                        )
                    )
                }

                // 3個以上柱がある場合は全体も表示する
                if 3 <= pillars.count {
                    params.append(
                        DimensionParam(
                            position: position,
                            p0: pillars.first!,
                            p1: pillars.last!,
                            offset: offset * 2,
                            rootOffset: rootOffset
                        )
                    )
                }
                
                params.forEach {
                    switch $0.position {
                    case .left:
                        self.dimensions.append(
                            Dimension(
                                p0: CGPoint(x: frame.minX - $0.offset, y: $0.p0.position.y),
                                p1: CGPoint(x: frame.minX - $0.offset, y: $0.p1.position.y),
                                rootPosition0: !self._simply ? $0.p0.position : CGPoint(x: frame.minX - $0.rootOffset, y: $0.p0.position.y),
                                rootPosition1: !self._simply ? $0.p1.position : CGPoint(x: frame.minX - $0.rootOffset, y: $0.p1.position.y)
                            )
                        )
                    case .right:
                        self.dimensions.append(
                            Dimension(
                                p0: CGPoint(x: frame.maxX + $0.offset, y: $0.p0.position.y),
                                p1: CGPoint(x: frame.maxX + $0.offset, y: $0.p1.position.y),
                                rootPosition0: !self._simply ? $0.p0.position : CGPoint(x: frame.maxX + $0.rootOffset, y: $0.p0.position.y),
                                rootPosition1: !self._simply ? $0.p1.position : CGPoint(x: frame.maxX + $0.rootOffset, y: $0.p1.position.y)
                            )
                        )
                    case .top:
                        self.dimensions.append(
                            Dimension(
                                p0: CGPoint(x: $0.p0.position.x, y: frame.minY - $0.offset),
                                p1: CGPoint(x: $0.p1.position.x, y: frame.minY - $0.offset),
                                rootPosition0: !self._simply ? $0.p0.position : CGPoint(x: $0.p0.position.x, y: frame.minY - $0.rootOffset),
                                rootPosition1: !self._simply ? $0.p1.position : CGPoint(x: $0.p1.position.x, y: frame.minY - $0.rootOffset)
                            )
                        )
                    case .bottom:
                        self.dimensions.append(
                            Dimension(
                                p0: CGPoint(x: $0.p0.position.x, y: frame.maxY + $0.offset),
                                p1: CGPoint(x: $0.p1.position.x, y: frame.maxY + $0.offset),
                                rootPosition0: !self._simply ?  $0.p0.position : CGPoint(x: $0.p0.position.x, y: frame.maxY + $0.rootOffset),
                                rootPosition1: !self._simply ?  $0.p1.position : CGPoint(x: $0.p1.position.x, y: frame.maxY + $0.rootOffset)
                            )
                        )
                    }
                }
            }
        }
    }
}
