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
    @State private var model = RoomCaptureModel.shared
    
    @State private var isScanning = false
    @State private var isSaved = false
    @State private var isShowingFloorPlan = false
    @State private var isPaused = false
    
    // MARK: - View Body
    var body: some View {
        ZStack {
            // The RoomCaptureView
            RoomCaptureRepresentable()
                .ignoresSafeArea()
            
            VStack {
                if self.model.showSnapshot,
                   let image = self.model.lastSnapshot
                {
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .frame(
                                width: geometry.size.width / 3,
                                height: geometry.size.height / 3
                            )
                            .padding()
                        
                    }
                }

                Spacer()
                
                HStack {
                    Spacer()
                    
                    if !self.isScanning,
                       !self.isSaved
                    {
                        Button("はじめから") {
                            self.resetTracking()
                            self.startSession()
                        }
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .fontWeight(.bold)
                        .padding(.bottom)
                    }
                    
                    if self.model.canNextScan,
                       !self.isScanning,
                       !self.isSaved
                    {
                        Button("つづきから") {
                            self.startSession()
                        }
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .fontWeight(.bold)
                        .padding(.bottom)
                    }
                    
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
                        
                        Button("完了") {
                            stopSession()
                        }
                        .disabled(!self.model.canSave)
                        .padding()
                        .background(self.model.canSave ? Color("AccentColor") : .gray)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .fontWeight(.bold)
                        .padding(.bottom)
                    }

                    if self.isSaved {
                        Button("平面図を作成") {
                            isShowingFloorPlan = true
                        }
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .fontWeight(.bold)
                        .padding(.bottom)
                    }
                    
                    Spacer()
                }
            }
        }
        
        // Start the scan session when the view appears
        .onAppear {
            self.load()
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
    
    private func load() {
        isScanning = false
        self.model.load()
        // Prevent the screen from sleeping
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    private func resetTracking() {
        self.model.resetTracking()
    }
    
    private func startSession() {
        self.isScanning = true
        self.model.startSession()
    }
    
    private func stopSession() {
        self.isScanning = false
        self.model.stopSession()
        self.isSaved = true

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
