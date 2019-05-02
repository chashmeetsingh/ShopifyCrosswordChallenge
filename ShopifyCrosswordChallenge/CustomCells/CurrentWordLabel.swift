//
//  CurrentWordLabel.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 28/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

// Custom Label with predefined edge insets
class CurrentWordLabel: UILabel {
  
  @IBInspectable var topInset: CGFloat = 16.0
  @IBInspectable var bottomInset: CGFloat = 16.0
  @IBInspectable var leftInset: CGFloat = 16.0
  @IBInspectable var rightInset: CGFloat = 16.0
  
  override func drawText(in rect: CGRect) {
    let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
    super.drawText(in: rect.inset(by: insets))
  }
  
  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
  }
  
}
