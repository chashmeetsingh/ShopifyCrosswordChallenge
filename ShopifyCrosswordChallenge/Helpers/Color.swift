//
//  Color.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 29/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

extension UIColor {
  
  static let customRed = UIColor(red: 1.0, green: 0.0, blue: 77.0/255.0, alpha: 1.0)
  static let customBlue = UIColor.blue
  static let customGreen = UIColor(red: 35.0/255.0 , green: 233/255, blue: 173/255.0, alpha: 1.0)
  static let customYellow = UIColor(red: 1, green: 209/255, blue: 77.0/255.0, alpha: 1.0)
  
  static func getRandomColor() -> UIColor {
    let red = CGFloat(drand48())
    let green = CGFloat(drand48())
    let blue = CGFloat(drand48())
    return UIColor(red: red, green: green, blue: blue, alpha: 1)
  }
  
  static func defaultColor() -> UIColor {
    return UIColor(red:0.20, green:0.25, blue:0.60, alpha:1.0)
  }
  
}
