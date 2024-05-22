//
//  FloorPlanModel.swift
//  RoomPlan 2D
//
//  Created by Takashi Murata on 2024/04/30.
//

import SwiftUI
import RoomPlan
import Observation

@Observable
final class FloorPlanModel {
    var structure: CapturedStructure
    var sharedUrl: URL?
    
    var scene: FloorPlan.Scene
    
    var isPresentedAcitivityView: Bool = false

    init(structure: CapturedStructure) {
        self.structure = structure
        self.scene = FloorPlan.Scene(capturedStructure: structure)
    }
    
    func export(structure: CapturedStructure) throws {
        let exportFolderURL = try self.createTmpExportFolder()
        let meshDestinationURL = exportFolderURL.appending(path: "floorplan.usdz")
        
        if 1 < structure.rooms.count {
            try self.createExportData(structure: structure, meshDestinationURL: meshDestinationURL)
        } else if let room = structure.rooms.first {
            try self.createExportData(room: room, meshDestinationURL: meshDestinationURL)
        }
        
        self.sharedUrl = exportFolderURL
        self.isPresentedAcitivityView = true
    }
    
    /// Exports the given captured structure in JSON format to a URL.
    private func exportJson(from capturedStructure: CapturedStructure, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(capturedStructure)
        try data.write(to: url)
    }

    private func exportJson(from capturedRoom: CapturedRoom, to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(capturedRoom)
        try data.write(to: url)
    }

    /// Exports the merged captured structure in JSON and USDZ formats to a URL.
    private func createExportData(
        structure: CapturedStructure,
        meshDestinationURL: URL?
    ) throws {
        guard let meshDestinationURL else { return }
        let roomDestinationURL = meshDestinationURL.deletingLastPathComponent().appending(path: "capturedRoom.json")
        try exportJson(from: structure, to: roomDestinationURL)
        let metadataDestinationURL = meshDestinationURL.deletingLastPathComponent().appending(path: "floorplan.plist")
        try structure.export(
            to: meshDestinationURL,
            metadataURL: metadataDestinationURL,
            exportOptions: [.mesh]
        )
    }    
    
    /// Exports the merged captured structure in JSON and USDZ formats to a URL.
    private func createExportData(
        room: CapturedRoom,
        meshDestinationURL: URL?
    ) throws {
        guard let meshDestinationURL else { return }
        let roomDestinationURL = meshDestinationURL.deletingLastPathComponent().appending(path: "capturedRoom.json")
        try exportJson(from: room, to: roomDestinationURL)
        let metadataDestinationURL = meshDestinationURL.deletingLastPathComponent().appending(path: "floorplan.plist")
        try room.export(
            to: meshDestinationURL,
            metadataURL: metadataDestinationURL,
            exportOptions: [.mesh]
        )
    }

    /// Provides a temporary location on disk to export a 3D model to.
    private func createTmpExportFolder(
        tmpFolderURL: URL = FileManager.default.temporaryDirectory) throws -> URL {
        let exportFolderURL = tmpFolderURL.appending(path: "FloorPlanExported")
        if FileManager.default.fileExists(atPath: exportFolderURL.path()) {
            try FileManager.default.removeItem(at: exportFolderURL)
        }
        try FileManager.default.createDirectory(
            at: exportFolderURL,
            withIntermediateDirectories: true
        )
        return exportFolderURL
    }
    
    func reloadScene(by module: FloorPlan.Module) {
        self.scene.reload(by: module, simpleDimension: self.scene.simpleDimension)
    }
    
    func reloadScene(simpleDimension: Bool) {
        self.scene.reload(by: self.scene.module, simpleDimension: simpleDimension)
    }
}
