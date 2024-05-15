//
//  FloorPlan+Preference.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 12/03/2023.
//

import UIKit

extension FloorPlan {
    final class Preference {
        private init() {}
        
        static let shared: Preference = .init()
        
        var scalingFactor: CGFloat = 1
        
        let m2mm: CGFloat = 1000
        
        var deviceScale: CGFloat {
            UIDevice.current.userInterfaceIdiom == .pad ? 1 : 1.5
        }
        
        
        // Colors
        let bgColor: UIColor = .white
        let surfaceColor: UIColor = .black
        let dimensionColor: UIColor = .red
        let wallColor: UIColor = .clear
        let windowColor: UIColor = .green
        let openingColor: UIColor = .gray
        let doorColor: UIColor = .orange
        let pillarColor: UIColor = .white
        
        // Line widths
        var surfaceWidth: CGFloat { 4.0 * self.scalingFactor * self.deviceScale }
        var hideSurfaceWidth: CGFloat { 6.0 * self.scalingFactor * self.deviceScale }
        var doorDashWidth: CGFloat { 4.8 * self.scalingFactor * self.deviceScale }
        var doorDashSpan: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
        var windowWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
        var windowRectWidth: CGFloat { 8.0 * self.scalingFactor * self.deviceScale }
        var doorArcWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
        var objectOutlineWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
        var rectLineWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
        var dimensionWidth: CGFloat { 1.6 * self.scalingFactor * self.deviceScale }
        
        // Depth
        var defaultWallDepth: CGFloat { 0.16 * self.m2mm }
        var otherDepth: CGFloat { 0.05 * self.m2mm }
        
        // label
        let fontColor: UIColor = .black
        var fontSize: CGFloat { 20 * self.scalingFactor * self.deviceScale }
        let fontName: String = "HelveticaNeue-Bold"
        
        // zPositions
        let zSurface: CGFloat = 0
        let zWall: CGFloat = 0
        let zHideSurface: CGFloat = 1
        let zWindow: CGFloat = 11
        let zDoor: CGFloat = 20
        let zDoorArc: CGFloat = 21
        let zObject: CGFloat = 30
        let zObjectOutline: CGFloat = 31
        let zPillar: CGFloat = 32
        let zDimension: CGFloat = 40
    }
}
