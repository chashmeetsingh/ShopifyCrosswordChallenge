//
//  Difficulty.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 28/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import Foundation

enum Difficulty {
  case easy
  case medium
  case hard
  
  var directions: [Direction] {
    switch self {
    case .easy:
      return [.leftToRight, .topToBottom].shuffled()
    case .medium:
      return [.leftToRight, .topToBottom, .rightToLeft, .bottomToTop].shuffled()
    case .hard:
      return Direction.allCases.shuffled()
    }
  }
}
