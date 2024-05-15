//
//  FloorPlanNodeProtocol.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/05/15.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation

protocol FloorPlanNodeProtocol {
    var priority: CGFloat { get }
    
    func draw()
}
