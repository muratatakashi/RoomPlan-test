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
    
    private var scene: FloorPlan.Scene
    
    init(structure: CapturedStructure) {
        self.structure = structure
        self.scene = FloorPlan.Scene(capturedStructure: structure)
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
    
    
    private lazy var _910Button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("910", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(m910ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func m910ButtonTapped() {
        self.scene.reload(by: .m910, simpleDimension: self.scene.simpleDimension)
    }
    
    private lazy var _985Button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("985", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(m985ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func m985ButtonTapped() {
        self.scene.reload(by: .m985, simpleDimension: self.scene.simpleDimension)
    }
    
    private lazy var _1000Button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("1000", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(m1000ButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func m1000ButtonTapped() {
        self.scene.reload(by: .m1000, simpleDimension: self.scene.simpleDimension)
    }
    
    private lazy var _rawButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("raw", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(rawButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func rawButtonTapped() {
        self.scene.reload(by: .none, simpleDimension: self.scene.simpleDimension)
    }
    
    private lazy var _dimensionButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("寸法切り替え", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(dimensionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc
    private func dimensionButtonTapped() {
        self.scene.reload(by: self.scene.module, simpleDimension: !self.scene.simpleDimension)
    }
    
    private func setup() {
        
        let vc = UIHostingController(rootView: SpriteView(scene: self.scene))
        self.addChild(vc)
        vc.view.frame = view.bounds
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        stackView.addArrangedSubview(self._dismissButton)
        stackView.addArrangedSubview(self._910Button)
        stackView.addArrangedSubview(self._985Button)
        stackView.addArrangedSubview(self._1000Button)
        stackView.addArrangedSubview(self._rawButton)
        
        self.view.addSubview(stackView)
        self.view.addSubview(self._dimensionButton)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            
            self._dimensionButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: -8),
            self._dimensionButton.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            
            self._910Button.heightAnchor.constraint(equalToConstant: 32),
            self._985Button.heightAnchor.constraint(equalToConstant: 32),
            self._1000Button.heightAnchor.constraint(equalToConstant: 32),
            self._rawButton.heightAnchor.constraint(equalToConstant: 32),
            self._dimensionButton.heightAnchor.constraint(equalToConstant: 32),

            self._910Button.widthAnchor.constraint(equalToConstant: 70),
            self._985Button.widthAnchor.constraint(equalToConstant: 70),
            self._1000Button.widthAnchor.constraint(equalToConstant: 70),
            self._rawButton.widthAnchor.constraint(equalToConstant: 70),
            self._dimensionButton.widthAnchor.constraint(equalToConstant: 100),
        ])
    }
    
    @objc
    private func dismissButtonTapped() {
        self.dismiss(animated: true)
    }
}

