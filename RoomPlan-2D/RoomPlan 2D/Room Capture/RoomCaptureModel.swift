//
//  RoomCaptureModel.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 24/02/2023.
//

import Foundation
import RoomPlan

class RoomCaptureModel: RoomCaptureSessionDelegate {
    
    // Singleton
    static let shared = RoomCaptureModel()
    
    // The capture view
    let roomCaptureView: RoomCaptureView
    
    // Capture and room builder configuration
    private let captureSessionConfig: RoomCaptureSession.Configuration
    private let roomBuilder: RoomBuilder
    
    var capturedRooms: [CapturedRoom] = []

    // The final scan result
    var finalStructure: CapturedStructure?
    
    private var _isFinished: Bool = false
    
    
    // Required functions to conform to NSCoding protocol
    func encode(with coder: NSCoder) {
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error when initializing RoomCaptureModel")
    }
    
    // Private initializer. Accessed by shared.
    private init() {
        roomCaptureView = RoomCaptureView(frame: .zero)
        captureSessionConfig = RoomCaptureSession.Configuration()
        roomBuilder = RoomBuilder(options: [.beautifyObjects])
        
        roomCaptureView.captureSession.delegate = self
    }
        
    // Start and stop the capture session. Available from our RoomCaptureScanView.
    func startSession() {
        self.capturedRooms = []
        self._isFinished = false
        roomCaptureView.captureSession.run(configuration: captureSessionConfig)
    }
    
    func stopSession() {
        self._isFinished = true
        roomCaptureView.captureSession.stop()
    }
    
    func pauseSession() {
        roomCaptureView.captureSession.stop(pauseARSession: false)
    }
    
    func restartSession() {
        roomCaptureView.captureSession.run(configuration: captureSessionConfig)
    }
    
    // Create the final scan result: a CapturedRoom object
    func captureSession(
        _ session: RoomCaptureSession,
        didEndWith data: CapturedRoomData,
        error: Error?
    ) {
        if let error {
            print("Error ending capture session; \(error)")
        }
        
        Task {
            guard let capturedRoom = try? await roomBuilder.capturedRoom(from: data) else {
                return
            }
            
            self.capturedRooms.append(capturedRoom)
            
            // 終わった時点で複数部屋あれば合成
            if self._isFinished,
               !self.capturedRooms.isEmpty
            {
                let builder = StructureBuilder(options: [.beautifyObjects])
                self.finalStructure = try? await builder.capturedStructure(from: self.capturedRooms)
            }
        }
    }
}
