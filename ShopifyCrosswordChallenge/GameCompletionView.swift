//
//  ReconfigureView.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 29/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

class GameCompletionView: UIView, Modal {
  
  var delegate: CrosswordViewController!
  var emitter = CAEmitterLayer()
  var confettiView: ConfettiView!
  
  lazy var backgroundView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
    return view
  }()
  
  var dialogView: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    view.backgroundColor = .white
    view.layer.cornerRadius = 16
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let congratsIV: UIImageView = {
    let iv = UIImageView()
    iv.image = UIImage.congratulations
    iv.contentMode = .scaleAspectFit
    iv.translatesAutoresizingMaskIntoConstraints = false
    return iv
  }()
  
  lazy var resetButton: UIButton = {
    let button = UIButton()
    button.setTitle("Reset Word Search", for: .normal)
    button.backgroundColor = UIColor.defaultColor()
    button.setTitleColor(.white, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    button.layer.cornerRadius = 16
    return button
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupView() {
    isHidden = true
    addConfettiView()
    let frameWidth = frame.width - 64

    addSubview(backgroundView)
    backgroundView.fillSuperview()

    addSubview(dialogView)
    let dialogFrameSize = CGSize(width: frameWidth, height: frameWidth)
    dialogView.centerInSuperview(size: dialogFrameSize)

    dialogView.addSubview(resetButton)
    let resetButtonSize = CGSize(width: dialogView.frame.width, height: 44)
    resetButton.anchor(top: nil, leading: dialogView.leadingAnchor, bottom: dialogView.bottomAnchor, trailing: dialogView.trailingAnchor, padding: UIEdgeInsets.init(top: 0, left: 16, bottom: 16, right: 16), size: resetButtonSize)

    dialogView.addSubview(congratsIV)
    let imageFrameSize = CGSize(width: dialogView.frame.width, height: frameWidth / 2)
    congratsIV.anchor(top: dialogView.topAnchor, leading: dialogView.leadingAnchor, bottom: nil, trailing: dialogView.trailingAnchor, padding: UIEdgeInsets.init(top: 4, left: 4, bottom: 0, right: 4), size: imageFrameSize)

    for constraint in dialogView.constraints {
      if constraint.firstAttribute == .height {
        constraint.constant = resetButtonSize.height + imageFrameSize.height
      }
    }
  }
  
  func addConfettiView() {
    // Create confetti view
    confettiView = ConfettiView(frame: self.bounds)
    
    // Set colors (default colors are red, green and blue)
    confettiView.colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
                           UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
                           UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
                           UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
                           UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
    
    // Set intensity (from 0 - 1, default intensity is 0.5)
    confettiView.intensity = 0.5
    
    // Set type
    confettiView.type = .diamond
    
    // For custom image
    // confettiView.type = .Image(UIImage(named: "diamond")!)
    
    // Add subview
    addSubview(confettiView)
    confettiView.startConfetti()
  }
  
  func showView() {
    isHidden = false
  }
  
  @objc func resetButtonTapped() {
    dismiss(animated: true)
    delegate.resetState()
    isHidden = true
  }
  
}
