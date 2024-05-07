//
//  FloorPlanPreference.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 12/03/2023.
//

import UIKit

final class FloorPlanPreference {
    private init() {}
    
    static let shared: FloorPlanPreference = .init()
    
    var scalingFactor: CGFloat = 1
    
    var m2mm: CGFloat { 1000 }
    
    // Colors
    let bgColor: UIColor = .white
    let surfaceColor: UIColor = .black
    let dimensionColor: UIColor = .red
    
    // Line widths
    var surfaceWith: CGFloat { 4.0 * self.scalingFactor }
    var hideSurfaceWith: CGFloat { 6.0 * self.scalingFactor }
    var doorDashWidth: CGFloat { 4.8 * self.scalingFactor }
    var doorDashSpan: CGFloat { 1.6 * self.scalingFactor }
    var windowWidth: CGFloat { 1.6 * self.scalingFactor }
    var windowRectWidth: CGFloat { 8.0 * self.scalingFactor }
    var doorArcWidth: CGFloat { 1.6 * self.scalingFactor }
    var objectOutlineWidth: CGFloat { 1.6 * self.scalingFactor }
    var rectLineWidth: CGFloat { 1.6 * self.scalingFactor }
    var dimensionWidth: CGFloat { 1.6 * self.scalingFactor }
    
    // label
    let fontColor: UIColor = .black
    var fontSize: CGFloat { 20 * self.scalingFactor }
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


