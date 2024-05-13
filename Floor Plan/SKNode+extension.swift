//
//  SKNode+extension.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/13.
//  Copyright © 2024 Apple. All rights reserved.
//

import SpriteKit

extension SKNode {
    func convertWorld(position localPosition: CGPoint) -> CGPoint {
        guard let scene = self.scene else {
            return localPosition
        }
        return self.convert(localPosition, to: scene)
    }
}
