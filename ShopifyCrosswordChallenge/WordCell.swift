//
//  WordCell.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 29/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

class WordCell: UICollectionViewCell {
  
  var word: Word! {
    didSet {
      setupLabel()
    }
  }
  
  let wordLabel: UILabel = {
    let label = UILabel()
    label.textColor = .white
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "Something"
    label.textAlignment = .center
    return label
  }()
  
  func setupLabel() {
    addSubview(wordLabel)
    wordLabel.fillSuperview()
    wordLabel.text = word.text
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = .darkGray
    layer.cornerRadius = 10
    clipsToBounds = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
