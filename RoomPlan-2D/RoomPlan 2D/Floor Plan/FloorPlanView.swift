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
    @State var model: FloorPlanModel
    
    var structure: CapturedStructure {
        self.model.structure
    }
    
    var onDismiss: (()->Void)
    
    private func share() {
        do {
            try self.model.export(structure: self.structure)
        } catch {
        }
    }
    
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
                    
                    Button(action: self.share) {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                    }
                    .padding(.trailing)
                    .padding(.top)
                }
                Spacer()
            }
        }
        .sheet(isPresented: self.$model.isPresentedAcitivityView) {
            ActivityView(
                activityItems: [self.model.sharedUrl!],
                applicationActivities: nil
            ) {
                // キャンセル
                self.model.isPresentedAcitivityView.toggle()
            } onShared: {
                // 完了
                self.model.isPresentedAcitivityView.toggle()
             }
            .presentationDetents([.medium, .large])
        }
    }
}
