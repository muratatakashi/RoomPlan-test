//
//  RoomCaptureView.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 24/02/2023.
//

import SwiftUI
import _SpriteKit_SwiftUI

struct RoomCaptureScanView: View {
    // MARK: - Properties & State
    private let model = RoomCaptureModel.shared
    
    @State private var isScanning = false
    @State private var isShowingFloorPlan = false
    @State private var isPaused = false
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            // The RoomCaptureView
            RoomCaptureRepresentable()
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()

                    if self.isScanning {
                        Button(self.isPaused ? "再開" : "次の部屋へ") {
                            if self.isPaused {
                                self.restartSession()
                            } else {
                                self.pauseSession()
                            }
                        }
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .fontWeight(.bold)
                        .padding(.bottom)
                        Spacer()
                    }

                    Button(isScanning ? "完了" : "平面図を作成") {
                        if isScanning {
                            stopSession()
                        } else {
                            isShowingFloorPlan = true
                        }
                    }
                    .padding()
                    .background(Color("AccentColor"))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .fontWeight(.bold)
                    .padding(.bottom)
                    
                    Spacer()
                }
            }
        }
        
        // Start the scan session when the view appears
        .onAppear {
            startSession()
        }
        
        // Show the floor plan in full screen
        .fullScreenCover(isPresented: $isShowingFloorPlan) {
            if let structure = model.finalStructure {
                FloorPlanView(model: FloorPlanModel(structure: structure)) {
                    self.isShowingFloorPlan.toggle()
                }
            }
        }
    }
    
    private func startSession() {
        isScanning = true
        model.startSession()
        
        // Prevent the screen from sleeping
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func stopSession() {
        isScanning = false
        model.stopSession()
        
        // Enable the screen to sleep again
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func pauseSession() {
        isPaused = true
        self.model.pauseSession()
    }
    
    private func restartSession() {
        isPaused = false
        self.model.restartSession()
    }
}

struct RoomCaptureScanView_Previews: PreviewProvider {
    static var previews: some View {
        RoomCaptureScanView()
    }
}
