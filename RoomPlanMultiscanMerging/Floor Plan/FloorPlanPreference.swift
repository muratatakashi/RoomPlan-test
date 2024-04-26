//
//  FloorPlanPreference.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 12/03/2023.
//

import UIKit

struct FloorPlanPreference {
    private init() {}
    
    static let shared: FloorPlanPreference = .init()
    
    // Universal scaling factor
    let scalingFactor: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 200 : 200

    // Colors
    let bgColor: UIColor = .white
    let surfaceColor: UIColor = .black
    let dimensionColor: UIColor = .red

    // Line widths
    let surfaceWith: CGFloat = 22.0
    let hideSurfaceWith: CGFloat = 30//24.0
    let doorDashWidth: CGFloat = 24.0
    let doorDashSpan: CGFloat = 8.0
    let windowWidth: CGFloat = 8.0
    let windowRectWidth: CGFloat = 40.0
    let doorArcWidth: CGFloat = 8.0
    let objectOutlineWidth: CGFloat = 8.0
    let rectLineWidth: CGFloat = 8.0
    let dimensionWidth: CGFloat = 8.0
    
    // label
    let fontColor: UIColor = .black
    let fontSize: CGFloat = 100
    let fontName: String = "HelveticaNeue-Bold"

    // zPositions
    let zHideSurface: CGFloat = 1
    let zWindow: CGFloat = 10
    let zDoor: CGFloat = 20
    let zDoorArc: CGFloat = 21
    let zObject: CGFloat = 30
    let zObjectOutline: CGFloat = 31
    let zDimension: CGFloat = 40

}


