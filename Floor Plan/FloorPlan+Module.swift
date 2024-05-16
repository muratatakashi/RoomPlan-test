//
//  FloorPlan+Module.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/15.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

extension FloorPlan {
    enum Module {
        case m910
        case m985
        case m1000
        case other(size: CGFloat)
        case none
        
        var size: CGFloat? {
            switch self {
            case .m910: 910
            case .m985: 985
            case .m1000: 1000
            case .other(let size): size
            case .none: nil
            }
        }
        
        var div2: CGFloat? {
            guard let size = self.size else {
                return nil
            }
            return size / 2
        }
        
        var div4: CGFloat? {
            guard let size = self.size else {
                return nil
            }
            return size / 4
        }
        
        func corret(point: CGPoint) -> CGPoint {
            guard let unit = self.div4 else {
                // noneの場合は四捨五入
                return CGPoint(
                    x: round(point.x),
                    y: round(point.y)
                )
            }
            
            // 小数点以下は要らん
            var x = CGFloat(Int(point.x))
            var y = CGFloat(Int(point.y))
            
            // 割って四捨五入する
            let divX = round(x / unit)
            let divY = round(y / unit)
            
            // unitの倍数にする
            x = unit * divX
            y = unit * divY
            
            return CGPoint(x: x, y: y)
        }
    }
}
