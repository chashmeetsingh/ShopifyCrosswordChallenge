//
//  String+EstimatedFrame.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 01/05/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

extension String {
  
  func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
    return ceil(boundingBox.width)
  }
  
}
