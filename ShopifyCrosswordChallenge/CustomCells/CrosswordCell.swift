//
//  CrosswordCell.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 25/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

class CrosswordCell: UICollectionViewCell {
  
  lazy var charLabel: UILabel = {
    let label = UILabel()
    label.text = "-"
    label.textColor = .white
    label.font = UIFont.boldSystemFont(ofSize: 22)
    label.textAlignment = .center
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setupView()
    addCharLabel()
  }
  
  fileprivate func setupView() {
    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 0.4
    backgroundColor = UIColor(red: 0.19, green: 0.25, blue: 0.62, alpha: 1.0)
  }
  
  fileprivate func addCharLabel() {
    addSubview(charLabel)
    charLabel.fillSuperview()
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = 0
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
