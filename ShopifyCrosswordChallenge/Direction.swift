//
//  Direction.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 28/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import Foundation

enum Direction: CaseIterable {
  
  // Supported word orientations
  case leftToRight
  case topToBottom
  case rightToLeft
  case bottomToTop
  
  var movement: (x: Int, y: Int) {
    switch self {
    case .leftToRight:
      return (1, 0)
    case .topToBottom:
      return (0, 1)
    case .rightToLeft:
      return (-1, 0)
    case .bottomToTop:
      return (0, -1)
    }
  }
  
}
