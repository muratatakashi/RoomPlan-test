//
//  FloorPlanView.swift
//  RoomPlan 2D
//
//  Created by Takashi Murata on 2024/04/30.
//

import SwiftUI
import SpriteKit
import RoomPlan

struct FloorPlanView: View {
    @State var structure: CapturedStructure
    
    var onDismiss: (()->Void)
    
    var body: some View {
        ZStack {
            SpriteView(scene: FloorPlanScene(capturedStructure: self.structure))
            VStack {
                HStack {
                    Button(action: self.onDismiss) {
                        Text("閉じる")
                    }
                    .padding(.leading)
                    .padding(.top)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
