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
    
    var scene: FloorPlan.Scene {
        self.model.scene
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
            SpriteView(scene: self.scene)
            VStack {
                HStack {
                    Button(action: self.onDismiss) {
                        Text("閉じる")
                    }
                    .padding()

                    Spacer()
                    
                    Button(action: self.share) {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                    }
                    .padding(.trailing)
                    .padding(.top)
                }
                
                Spacer()
                
                HStack {
                    RoundedButton(
                        text: "raw",
                        textColor: .white,
                        backgroundColor: .gray,
                        fontWeight: .medium,
                        cornerRadius: 5,
                        width: 70,
                        height: 32
                    ) {
                        self.model.reloadScene(by: .none)
                    }
                    
                    RoundedButton(
                        text: "910",
                        textColor: .white,
                        backgroundColor: .gray,
                        fontWeight: .medium,
                        cornerRadius: 5,
                        width: 70,
                        height: 32
                    ) {
                        self.model.reloadScene(by: .m910)
                    }

                    RoundedButton(
                        text: "985",
                        textColor: .white,
                        backgroundColor: .gray,
                        fontWeight: .medium,
                        cornerRadius: 5,
                        width: 70,
                        height: 32
                    ) {
                        self.model.reloadScene(by: .m985)
                    }
                    
                    RoundedButton(
                        text: "1000",
                        textColor: .white,
                        backgroundColor: .gray,
                        fontWeight: .medium,
                        cornerRadius: 5,
                        width: 70,
                        height: 32
                    ) {
                        self.model.reloadScene(by: .m1000)
                    }

                    RoundedButton(
                        text: "寸法",
                        textColor: .white,
                        backgroundColor: .gray,
                        fontWeight: .medium,
                        cornerRadius: 5,
                        width: 70,
                        height: 32
                    ) {
                        self.model.reloadScene(simpleDimension: !self.scene.simpleDimension)
                    }
                }
                .padding()
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
