//
//  SAConfettiView.swift
//  Pods
//
//  Created by Sudeep Agarwal on 12/14/15.
//
//

import UIKit
import QuartzCore

class ConfettiView: UIView {
  
  var emitter: CAEmitterLayer!
  var colors: [UIColor]!
  var active :Bool!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {
    colors = Constants.colors
    startConfetti()
  }
  
  public func startConfetti() {
    emitter = CAEmitterLayer()
    
    emitter.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
    emitter.emitterShape = CAEmitterLayerEmitterShape.line
    emitter.emitterSize = CGSize(width: frame.size.width, height: 1)
    
    var cells = [CAEmitterCell]()
    for color in colors {
      cells.append(confettiWithColor(color: color))
    }
    
    emitter.emitterCells = cells
    layer.addSublayer(emitter)
    active = true
  }
  
  public func stopConfetti() {
    emitter?.birthRate = 0
    active = false
  }
  
  func confettiWithColor(color: UIColor) -> CAEmitterCell {
    let confetti = CAEmitterCell()
    confetti.birthRate = 20
    confetti.lifetime = 15
    confetti.lifetimeRange = 10
    confetti.color = color.cgColor
    confetti.velocity = getRandomVelocity()
    confetti.velocityRange = 0
    confetti.emissionLongitude = CGFloat(Double.pi)
    confetti.emissionRange = CGFloat(Double.pi)
    confetti.spin = 3.5
    confetti.spinRange = 0
    confetti.scale = 0.1
    confetti.scaleRange = 0.25
    confetti.scaleSpeed = CGFloat(-0.1)
    confetti.contents = getRandomImage().cgImage
    confetti.alphaSpeed = -1.0 / 14.0
    return confetti
  }
  
  public func isActive() -> Bool {
    return self.active
  }
  
  func getRandomVelocity() -> CGFloat {
    return data(data: Constants.velocities) as! CGFloat
  }
  
  private func getRandomImage() -> UIImage {
    return data(data: Constants.images) as! UIImage
  }
  
  private func data(data: [Any]) -> AnyObject {
    return data[Int.random(in: 0..<data.count)] as AnyObject
  }
  
}
