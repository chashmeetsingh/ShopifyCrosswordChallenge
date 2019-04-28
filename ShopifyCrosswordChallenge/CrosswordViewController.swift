//
//  ViewController.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 25/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

import UIKit

fileprivate let cellIdentifier = "cellId"

class CrosswordViewController: UIViewController {
  
  var cells = [String: UIView]()

  let words = ["SWIFT", "KOTLIN", "OBJECTIVEC", "VARIABLE", "JAVA", "MOBILE"]

  var wordSearch: WordSearch!
  
  let backgroundImageView: UIImageView = {
    let image = UIImage(named: "background")
    let iv = UIImageView(image: image)
    iv.contentMode = .scaleAspectFill
    return iv
  }()
  
  let contentStackView: UIStackView = {
    let sv = UIStackView()
    sv.axis = .vertical
    sv.distribution = .equalSpacing
    sv.backgroundColor = .red
    sv.alignment = .center
    sv.spacing = 16
    sv.translatesAutoresizingMaskIntoConstraints = false
    return sv
  }()
  
  var currentWordLabel: CurrentWordLabel = {
    let label = CurrentWordLabel()
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
    label.backgroundColor = UIColor(red: 0.19, green: 0.25, blue: 0.62, alpha: 1.0)
    label.layer.borderColor = UIColor.darkGray.cgColor
    label.layer.borderWidth = 0.7
    label.textAlignment = .center
    label.layer.cornerRadius = 16
    label.numberOfLines = 1
    label.clipsToBounds = true
    label.text = " "
    return label
  }()
  
  lazy var crosswordView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
    cv.backgroundColor = .black
    cv.dataSource = self
    cv.delegate = self
    cv.register(CrosswordCell.self, forCellWithReuseIdentifier: cellIdentifier)
    cv.isScrollEnabled = false
    cv.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
    cv.backgroundColor = .clear
    return cv
  }()
  
  var wordsFound = [String]()
  
  var width: CGFloat {
    get {
      return view.frame.width
    }
  }
  
  var cellWidth: CGFloat {
    get {
      return (width - 16) / 10
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupView()
    populateCrossword()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  func setupView() {
    view.addSubview(backgroundImageView)
    
    contentStackView.addArrangedSubview(currentWordLabel)
    contentStackView.addArrangedSubview(crosswordView)
    applyConstraints()
    
    view.addSubview(contentStackView)
    contentStackView.centerInSuperview()
  }
  
  func applyConstraints() {
    [
      currentWordLabel.widthAnchor.constraint(equalToConstant: width - 16),
      crosswordView.widthAnchor.constraint(equalToConstant: width - 16),
      crosswordView.heightAnchor.constraint(equalToConstant: width - 16),
    ].forEach({$0.isActive = true})
  }
  
  func populateCrossword() {
    wordSearch = WordSearch(10, 10, words)
    wordSearch.generateGrid()
  }
  
  var wordGenerated = ""
  var keysUsed = [String]()
  
  var currentValues: [String]! {
    didSet {
      wordGenerated = getCurrentWord()
      print(wordGenerated)
      currentWordLabel.text = wordGenerated
    }
  }
  
  @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: crosswordView)
    
    let column = Int(location.x / cellWidth)
    let row = Int(location.y / cellWidth)
    
    let key = "\(row)|\(column)"
    
    guard let currentCell = cells[key] as? CrosswordCell else { return }
    
    switch gesture.state {
    case .began:
      // print("began")
      currentValues = []
      if !currentValues.contains(key) {
        currentValues.append(key)
      }
      break
    case .changed:
      // print("changed")
      if !currentValues.contains(key) {
        currentValues.append(key)
      } else if currentValues.lastIndex(of: key) != currentValues.count - 1 {
        let key = currentValues[currentValues.count - 1]
        currentValues.removeLast()
        
        guard let cell = cells[key] as? CrosswordCell else { return }
        
        if keysUsed.contains(key) { return }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
          cell.layer.transform = CATransform3DIdentity
          cell.layer.cornerRadius = 0
        }, completion: nil)
        
      }
      break
    case .ended:
      // print("ended")
      
      if wordsFound.contains(wordGenerated) { return }
      
      if !words.contains(wordGenerated) {
        for value in currentValues {
          guard let someCell = cells[value] else { continue }
          
          if keysUsed.contains(value) { continue }
          
          UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            someCell.layer.transform = CATransform3DIdentity
            someCell.layer.cornerRadius = 0
          }, completion: nil)
        }
        return
      } else {
        for value in currentValues {
          keysUsed.append(value)
        }
      }
      
      wordsFound.append(wordGenerated)
      
      if let initialView = cells[currentValues[0]], let destinationView = cells[currentValues[currentValues.count - 1]] {
        let startPoint = CGPoint(x: initialView.center.x + view.safeAreaInsets.left, y: initialView.center.y)
        let endPoint = CGPoint(x: destinationView.center.x + view.safeAreaInsets.left, y: destinationView.center.y)
        
        let path = UIBezierPath()
        let shapeLayer = CAShapeLayer()
        
        let strokeView = UIView()
        
        shapeLayer.strokeColor = UIColor(red:0.96, green:0.00, blue:0.34, alpha:1.0).cgColor
        shapeLayer.fillColor = UIColor(red: 26/255, green: 72/255, blue: 149/255, alpha: 1).cgColor
        shapeLayer.lineWidth = (cellWidth * 0.8)
        strokeView.layer.addSublayer(shapeLayer)
        
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        shapeLayer.path = path.cgPath
        
        crosswordView.addSubview(strokeView)
        crosswordView.sendSubviewToBack(strokeView)
      }
      break
    case .cancelled:
      print("cancelled")
      break
    default:
      print("unknow gesture state")
    }
    
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      currentCell.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
      currentCell.layer.cornerRadius = self.cellWidth / 2
    }, completion: nil)
    
  }
  
  func getCurrentWord() -> String {
    var word = ""
    for key in currentValues {
      guard let cell = cells[key] as? CrosswordCell else { return "" }
      word += cell.charLabel.text!
    }
    return word
  }

}

extension CrosswordViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return wordSearch.numberOfRows
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return wordSearch.numberOfColumns
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CrosswordCell
    let row = indexPath.section
    let column = indexPath.item
    cell.charLabel.text = "\(wordSearch.crossword[row][column].letter)"
    
    let key = "\(row)|\(column)"
    cells[key] = cell
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (width - 16) / 10, height: (width - 16) / 10)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0
  }
  
}
