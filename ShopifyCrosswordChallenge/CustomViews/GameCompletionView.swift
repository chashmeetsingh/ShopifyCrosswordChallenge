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
  var confettiView: ConfettiView = {
    let view = ConfettiView()
    return view
  }()
  
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
    button.setTitle("Restart Game", for: .normal)
    button.backgroundColor = UIColor.defaultColor()
    button.setTitleColor(.white, for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
    button.layer.cornerRadius = 16
    return button
  }()
  
  var frameWidth: CGFloat {
    get {
      if UIDevice.current.orientation.isPortrait {
        return frame.width - 64
      } else {
        return frame.height - 64
      }
    }
  }
  
  func setupView() {
    addConfettiView()

    addSubview(backgroundView)
    backgroundView.fillSuperview()

    addSubview(dialogView)
    let dialogFrameSize = CGSize(width: frameWidth, height: frameWidth / 2 + 16)
    dialogView.centerInSuperview(size: dialogFrameSize)

    dialogView.addSubview(resetButton)
    let resetButtonSize = CGSize(width: 0, height: 40)
    resetButton.anchor(top: nil, leading: dialogView.leadingAnchor, bottom: dialogView.bottomAnchor, trailing: dialogView.trailingAnchor, padding: UIEdgeInsets.init(top: 0, left: 16, bottom: 16, right: 16), size: resetButtonSize)

    dialogView.addSubview(congratsIV)
    congratsIV.anchor(top: dialogView.topAnchor, leading: dialogView.leadingAnchor, bottom: resetButton.topAnchor, trailing: dialogView.trailingAnchor, padding: UIEdgeInsets.init(top: 4, left: 4, bottom: 0, right: 4), size: .zero)
  }
  
  func addConfettiView() {
    // Create confetti view
    confettiView = ConfettiView(frame: self.bounds)
    
    // Add subview
    addSubview(confettiView)
  }
  
  func showView() {
    setupView()
    show(animated: true)
  }
  
  @objc func resetButtonTapped() {
    dismiss(animated: true)
    delegate.resetState()
  }
  
}
