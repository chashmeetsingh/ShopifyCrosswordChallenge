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
  
  @objc func resetButtonTapped() {
    dismiss(animated: true)
    delegate.resetState()
  }
  
  func confettiWithColor(color: UIColor) -> CAEmitterCell {
    let confetti = CAEmitterCell()
    confetti.scale = 0.1
    confetti.birthRate = 20.0
    confetti.lifetime = 15
    confetti.lifetimeRange = 10
    confetti.color = color.cgColor
    confetti.velocity = getRandomVelocity()
    confetti.velocityRange = 0
    confetti.emissionLongitude = CGFloat(Double.pi)
    confetti.emissionRange = CGFloat(Double.pi)
    confetti.spin = 3.5
    confetti.spinRange = 0
    confetti.scaleRange = 0.25
    confetti.scaleSpeed = CGFloat(-0.1)
    confetti.contents = getRandomImage()
    confetti.alphaSpeed = -1.0 / 14.0
    
    return confetti
  }
  
  func startConfettiAnimation() {
    emitter.removeFromSuperlayer()
    isHidden = false
    
    emitter.emitterPosition = CGPoint(x: self.frame.size.width / 2, y: -10)
    emitter.emitterShape = CAEmitterLayerEmitterShape.line
    emitter.emitterSize = CGSize(width: self.frame.size.width, height: 2.0)
    emitter.renderMode = CAEmitterLayerRenderMode.additive
    
    let cells = Constants.colors.map({
      return confettiWithColor(color: $0)
    })
    
    emitter.emitterCells = cells
    
    emitter.birthRate = 1.0
    
    backgroundView.layer.addSublayer(emitter)
    //      animating = true
  }
  
  func stopConfettiAnimation(clear: Bool = false) {
    isHidden = true
    if clear {
      emitter.removeFromSuperlayer()
    } else {
      emitter.birthRate = 0
    }
    
    //      animating = false
  }
  
  func getRandomVelocity() -> CGFloat {
    return data(data: Constants.velocities) as! CGFloat
  }
  
  private func getRandomImage() -> UIImage {
    return data(data: Constants.images) as! UIImage
  }
  
  private func data(data: [Any]) -> AnyObject {
    return data[Int.random(in: 0..<data.count - 1)] as AnyObject
  }
  
}
