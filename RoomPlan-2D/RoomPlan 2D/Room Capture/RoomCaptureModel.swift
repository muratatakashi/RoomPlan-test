//
//  RoomCaptureModel.swift
//  RoomPlan 2D
//
//  Created by Dennis van Oosten on 24/02/2023.
//

import Foundation
import RoomPlan
import ARKit
import Observation

@Observable
final class RoomCaptureModel: NSObject, RoomCaptureSessionDelegate {
    
    // Singleton
    static let shared = RoomCaptureModel()
    
    // The capture view
    let roomCaptureView: RoomCaptureView
    
    // Capture and room builder configuration
    private let captureSessionConfig: RoomCaptureSession.Configuration
    private let roomBuilder: RoomBuilder
    
    private let _arConfiguration: ARWorldTrackingConfiguration
    private let _arSession = ARSession()
    
    var capturedRooms: [CapturedRoom] = []

    // The final scan result
    var finalStructure: CapturedStructure?
    
    // 最後に保存した時の写真
    var lastSnapshot: UIImage?
    var showSnapshot: Bool = false
    
    var canScan: Bool = false
    var canSave: Bool = false

    private var _isFinished: Bool = false
    
    
    // Required functions to conform to NSCoding protocol
    func encode(with coder: NSCoder) {
    }
    
    required init?(coder: NSCoder) {
        fatalError("Error when initializing RoomCaptureModel")
    }
    
    // Private initializer. Accessed by shared.
    private override init() {
//        roomCaptureView = RoomCaptureView(frame: .zero)
        roomCaptureView = RoomCaptureView(frame: .zero, arSession: self._arSession)
        captureSessionConfig = RoomCaptureSession.Configuration()
        roomBuilder = RoomBuilder(options: [.beautifyObjects])
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.environmentTexturing = .automatic
        self._arConfiguration = configuration

        super.init()
        
        roomCaptureView.captureSession.delegate = self
        self._arSession.delegate = self
    }
    
    func load() {
        self.canScan = false
        self.canSave = false
        self.loadExperience()
    }
    
    func resetTracking() {
        self._arConfiguration.initialWorldMap = nil
        self._arSession.run(self._arConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
        
    // Start and stop the capture session. Available from our RoomCaptureScanView.
    func startSession() {
        self.capturedRooms = []
        self._isFinished = false
        self.roomCaptureView.captureSession.run(configuration: captureSessionConfig)
        self.canSave = true
    }
    
    func stopSession() {
        self._isFinished = true
        self.canScan = false
        self.canSave = false
        roomCaptureView.captureSession.stop()
        self.saveExperience()
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
    
    private var _worldMapUrl: URL {
        do {
            return try FileManager.default
                .url(
                    for: .documentDirectory,
                     in: .userDomainMask,
                     appropriateFor: nil,
                     create: true
                ).appendingPathComponent("map.arexperience")
        } catch {
            fatalError("Can't get file save URL: \(error.localizedDescription)")
        }
    }
    
    private var _worldMapData: Data? {
        try? Data(contentsOf: self._worldMapUrl)
    }
    
    private var _lastWorldMap: ARWorldMap? {
        guard let data = self._worldMapData else {
            return nil
        }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
    }
    
    private func saveExperience() {
        guard let arSession = self.roomCaptureView.captureSession?.arSession else {
            return
        }
        
        self.roomCaptureView.captureSession?.arSession.getCurrentWorldMap(completionHandler: { worldMap, error in
            guard let worldMap = worldMap else {
                print("Can't get current world map", error?.localizedDescription ?? "")
                return
            }
            
            guard let snapshotAnchor = SnapshotAnchor(capturing: arSession) else {
                print("Can't take snapshot")
                return
            }
            worldMap.anchors.append(snapshotAnchor)
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                try data.write(to: self._worldMapUrl, options: [.atomic])
            } catch {
                print("Can't save map: \(error.localizedDescription)")
            }
        })
    }
    
    private func loadExperience() {
        guard let worldMap = self._lastWorldMap else {
            roomCaptureView.captureSession.arSession.run(self._arConfiguration)
            self.canScan = true
            return
        }
        
        if let snapshotData = worldMap.snapshotAnchor?.imageData,
           let snapshot = UIImage(data: snapshotData)
        {
            // 最後に撮影した部屋の写真を表示
            self.lastSnapshot = snapshot
        }
        
        worldMap.anchors.removeAll(where: { $0 is SnapshotAnchor })
        
        // リローカライズ開始
        self._arConfiguration.initialWorldMap = worldMap
        roomCaptureView.captureSession.arSession.run(self._arConfiguration)
        
        self.isRelocalizingMap = true
    }
    
    
    var isRelocalizingMap = false

}

extension RoomCaptureModel: ARSessionDelegate {
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
    
    /// - Tag: CheckMappingStatus
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Enable Save button only when the mapping status is good and an object has been placed
        switch frame.worldMappingStatus {
        case .extending, .mapped:
            break
        default:
            break
        }
//        statusLabel.text = """
//        Mapping: \(frame.worldMappingStatus.description)
//        Tracking: \(frame.camera.trackingState.description)
//        """
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    // MARK: - ARSessionObserver
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay.
//        sessionInfoLabel.text = "Session was interrupted"
        print("Session was interrupted")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required.
//        sessionInfoLabel.text = "Session interruption ended"
        print("Session interruption ended")
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
//        sessionInfoLabel.text = "Session failed: \(error.localizedDescription)"
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        
        // Remove optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
//        DispatchQueue.main.async {
//            // Present an alert informing about the error that has occurred.
//            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
//            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
//                alertController.dismiss(animated: true, completion: nil)
//                self._arConfiguration.initialWorldMap = nil
//                self._arSession.run(self._arConfiguration, options: [.resetTracking, .removeExistingAnchors])
//            }
//            alertController.addAction(restartAction)
//            self.present(alertController, animated: true, completion: nil)
//        }
        
        self.resetTracking()
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
        // Update the UI to provide feedback on the state of the AR experience.
        let message: String
        
        self.showSnapshot = false
        switch (trackingState, frame.worldMappingStatus) {
        case (.normal, .mapped),
            (.normal, .extending):
            message = "mapped !"
            self.canScan = true
            
//        case (.normal, _) where mapDataFromFile != nil && !isRelocalizingMap:
//            message = "Move around to map the environment or tap 'Load Experience' to load a saved experience."
//            
//        case (.normal, _) where mapDataFromFile == nil:
//            message = "Move around to map the environment."
            
        case (.limited(.relocalizing), _) where self.isRelocalizingMap:
            message = "Move your device to the location shown in the image."
            self.showSnapshot = true
            
        default:
            message = trackingState.localizedFeedback
        }
        
        print(message)
        
//        sessionInfoLabel.text = message
//        sessionInfoView.isHidden = message.isEmpty
    }
}
