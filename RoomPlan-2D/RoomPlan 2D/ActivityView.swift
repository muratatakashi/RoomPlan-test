//
//  ActivityView.swift
//  AniCap
//
//  Created by Takashi Murata on 2024/04/11.
//

import LinkPresentation
import SwiftUI

struct ActivityView: UIViewControllerRepresentable {
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    private(set) var onCanceled: ()->Void
    private(set) var onShared: ()->Void
    
    func makeUIViewController(
        context: Context
    ) -> UIActivityViewController
    {
        let controller = UIActivityViewController(
            activityItems: self.activityItems,
            applicationActivities: self.applicationActivities
        )
        controller.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            if !completed {
                self.onCanceled()
                return
            }
            self.onShared()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

