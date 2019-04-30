//
//  WordsCollectionView.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 29/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

fileprivate let cellIdentifier = "cellId"

class WordsCollectionView: UICollectionView {
  
  var words: [Word]!
  var wordsFound: [String] = [] {
    didSet {
      reloadData()
    }
  }

  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
    
    translatesAutoresizingMaskIntoConstraints = false
    setupCollectionView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    setupCollectionView()
  }
  
  func setupCollectionView() {
    delegate = self
    dataSource = self
    register(WordCell.self, forCellWithReuseIdentifier: cellIdentifier)
    backgroundColor = .clear
  }
  
}

extension WordsCollectionView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return words.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! WordCell
    let word = words[indexPath.item]
    cell.word = word
    cell.alpha = wordsFound.contains(word.text) ? 0.5 : 1
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let word = words[indexPath.item]
    let estimatedWidth = word.text.width(withConstrainedHeight: 20, font: .systemFont(ofSize: 17))
    return CGSize(width: estimatedWidth + 16, height: 28)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 8
  }
  
}

extension String {
  
  func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
    return ceil(boundingBox.width)
  }
}
