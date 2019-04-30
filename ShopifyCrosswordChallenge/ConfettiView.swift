//
//  SAConfettiView.swift
//  Pods
//
//  Created by Sudeep Agarwal on 12/14/15.
//
//

import UIKit
import QuartzCore

public class ConfettiView: UIView {
  
  public enum ConfettiType {
    case confetti
    case triangle
    case star
    case diamond
    case image(UIImage)
  }
  
  var emitter: CAEmitterLayer!
  public var colors: [UIColor]!
  public var intensity: Float!
  public var type: ConfettiType!
  private var active :Bool!
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  func setup() {
    colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
              UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
              UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
              UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
              UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
    intensity = 0.5
    type = .confetti
    active = false
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
    return data[Int.random(in: 0..<data.count - 1)] as AnyObject
  }
}
