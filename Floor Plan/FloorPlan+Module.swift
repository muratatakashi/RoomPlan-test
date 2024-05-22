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
        
        var size: CGFloat {
            switch self {
            case .m910: 910
            case .m985: 985
            case .m1000: 1000
            case .other(let size): size
            case .none: 1
            }
        }
        
        var span: CGFloat {
            switch self {
            case .m910: self.size / 3
            case .m985: self.size / 4
            case .m1000: self.size / 4
            case .other(let size): size
            case .none: self.size
            }
        }
        
        
        func corret(point: CGPoint) -> CGPoint {
            // 小数点以下は要らん
            var x = CGFloat(Int(point.x))
            var y = CGFloat(Int(point.y))
            
            // 割って四捨五入する
            let divX = floor(x / self.span)
            let divY = floor(y / self.span)
            
            // spanの倍数にする
            x = self.span * divX
            y = self.span * divY
            
            return CGPoint(x: x, y: y)
        }
  
        // 没
//        func corret(surfacePoint: SurfacePoint) -> SurfacePoint {
//            var start = surfacePoint.start
//            var end = surfacePoint.end
//            
//            var length = CGFloat(Int((end - start).length()))
//            
//            let v = (end - start).normalized()
//            
//            // 始点を補正して、補正した長さに合わせて終点を決める
//            start = self.corret(point: start)
//
//            let modLength = length.truncatingRemainder(dividingBy: self.unit)
//            length = self.unit * round(length / self.unit)
//            
////            if (self.unit / 2) < abs(modLength) {
////                // 理論値より大きくずれてたらそのまま足す
////                length += modLength
////            }
//            
//            end = start + (v * length)
//            end.x = round(end.x)
//            end.y = round(end.y)
//
//            return SurfacePoint(start: start, end: end)
//        }
    }
}
