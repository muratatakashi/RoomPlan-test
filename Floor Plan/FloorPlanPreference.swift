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
    
    let m2mm: CGFloat = 1000
    
    var deviceScale: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 1 : 1.5
    }
    
    
    // Colors
    let bgColor: UIColor = .white
    let surfaceColor: UIColor = .black
    let dimensionColor: UIColor = .red
    
    // Line widths
    var surfaceWith: CGFloat { 4.0 * self.scalingFactor * self.deviceScale }
    var hideSurfaceWith: CGFloat { 6.0 * self.scalingFactor * self.deviceScale }
    var doorDashWidth: CGFloat { 4.8 * self.scalingFactor * self.deviceScale }
    var doorDashSpan: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
    var windowWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
    var windowRectWidth: CGFloat { 8.0 * self.scalingFactor * self.deviceScale }
    var doorArcWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
    var objectOutlineWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
    var rectLineWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
    var dimensionWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
    
    // label
    let fontColor: UIColor = .black
    var fontSize: CGFloat { 20 * self.scalingFactor * self.deviceScale }
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


