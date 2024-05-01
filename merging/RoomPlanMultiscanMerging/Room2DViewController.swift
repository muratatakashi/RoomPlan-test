//
//  Room2DViewController.swift
//  RoomPlanMultiscanMerging
//
//  Created by Takashi Murata on 2024/04/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import UIKit
import SwiftUI
import SpriteKit
import RoomPlan

class Room2DViewController: UIViewController {
    private var structure: CapturedStructure
    
    init(structure: CapturedStructure) {
        self.structure = structure
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    private lazy var _dismissButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("閉じる", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private func setup() {
        
        let vc = UIHostingController(rootView: SpriteView(scene: FloorPlanScene(capturedStructure: self.structure)))
        self.addChild(vc)
        vc.view.frame = view.bounds
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        self.view.addSubview(self._dismissButton)
        NSLayoutConstraint.activate([
            self._dismissButton.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self._dismissButton.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
        ])
    }
    
    @objc
    private func dismissButtonTapped() {
        self.dismiss(animated: true)
    }
}

