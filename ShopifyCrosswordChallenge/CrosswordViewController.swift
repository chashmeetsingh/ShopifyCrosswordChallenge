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

  var words: [String] = ["SWIFT", "KOTLIN", "OBJECTIVEC", "VARIABLE", "JAVA", "MOBILE", "ANDROID", "IOS"]

  var wordSearch: WordSearchGenerator!
  
  var emitter = CAEmitterLayer()
  var animating = false
  
  var gameCompletionView: ReconfigureView!
  
  var colors: [UIColor] = [
    UIColor.customRed,
    UIColor.customBlue,
    UIColor.customGreen,
    UIColor.customYellow
  ]
  
  var images: [UIImage] = [
    UIImage.box,
    UIImage.triangle,
    UIImage.circle,
    UIImage.swirl
  ]
  
  var velocities: [Int] = [
    100,
    90,
    150,
    200
  ]
  
  @IBOutlet weak var currentWordLabel: CurrentWordLabel!
  @IBOutlet weak var crosswordCollectionView: UICollectionView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var wordsCollectionView: WordsCollectionView!
  
  var wordsFound = [String]() {
    didSet {
      scoreLabel.text = "Score: \(wordsFound.count)/\(wordSearch.words.count)"
      wordsCollectionView.wordsFound = wordsFound
      
      if wordsFound.count == wordSearch.words.count {
        gameComplete()
      }
    }
  }
  
  var width: CGFloat = 0
  
  var cellWidth: CGFloat {
    get {
      return width / 10
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCollectionView()
    populateCrossword()
    setupWordLabel()
    setupScoreLabel()
    setupGameCompletionView()
    setupWordsCollectionView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    setCrosswordViewWidth()
    updateConstraints()
    crosswordCollectionView.reloadData()
  }
  
  // Light status bar
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  // Regenerate bezier curves and invalidate layout on rotation
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    
    // Perform the following only after completion of the orientation
    coordinator.animate(alongsideTransition: nil) { _ in
      self.setCrosswordViewWidth()
      self.updateConstraints()
      self.crosswordCollectionView.collectionViewLayout.invalidateLayout()
      
      self.removeStrokeViews()
      self.regenerateStrokeViews()
      self.wordsCollectionView.reloadData()
    }
  }
  
  func setupWordsCollectionView() {
    wordsCollectionView.words = wordSearch.words.reversed()
  }
  
  func setupGameCompletionView() {
    gameCompletionView = ReconfigureView(frame: view.bounds)
    gameCompletionView.delegate = self
  }
  
  func resetState() {
    populateCrossword()
    wordsFound = []
    
    for key in keysUsed {
      setCellState(key: key, defaultState: true)
    }
    
    keysUsed = []
    keysForWordsFound = [:]
    removeStrokeViews()
    stopConfettiAnimation(clear: true)
    currentWordLabel.text = " "
    crosswordCollectionView.isUserInteractionEnabled = !crosswordCollectionView.isUserInteractionEnabled
    
    crosswordCollectionView.reloadData()
  }
  
  func gameComplete() {
    crosswordCollectionView.isUserInteractionEnabled = !crosswordCollectionView.isUserInteractionEnabled
    startConfettiAnimation()
    gameCompletionView.show(animated: true)
  }
  
  // Dynamically calculate width of collection view based on orientation
  fileprivate func setCrosswordViewWidth() {
    if UIDevice.current.orientation.isPortrait {
      width = containerView.frame.width - 32
    } else if UIDevice.current.orientation.isLandscape {
      let del: CGFloat = currentWordLabel.frame.height + 16 + 8
      width = containerView.frame.height - del
    }
  }
  
  func setupCollectionView() {
    crosswordCollectionView.register(CrosswordCell.self, forCellWithReuseIdentifier: cellIdentifier)
    crosswordCollectionView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture)))
    crosswordCollectionView.backgroundColor = .clear
    crosswordCollectionView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  // Update constraints when orientation is changed
  func updateConstraints() {
    crosswordCollectionView.constraints.forEach { (constraint) in
      if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
        constraint.constant = width
      }
    }
    crosswordCollectionView.setNeedsLayout()
    
    currentWordLabel.constraints.forEach { (constraint) in
      if constraint.firstAttribute == .width {
        constraint.constant = width
      }
    }
    currentWordLabel.setNeedsUpdateConstraints()
  }
  
  func setupWordLabel() {
    currentWordLabel.layer.borderColor = UIColor.darkGray.cgColor
    currentWordLabel.layer.borderWidth = 0.8
    currentWordLabel.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setupScoreLabel() {
    scoreLabel.text = "Score: \(wordsFound.count)/\(wordSearch.words.count)"
  }
  
  // Initialize grid with a set of words
  func populateCrossword() {
    wordSearch = WordSearchGenerator(10, 10, words)
    wordSearch.generateGrid()
  }
  
  var wordGenerated = ""
  var keysUsed = [String]()
  
  var currentValues: [String]! {
    didSet {
      wordGenerated = getCurrentWord()
      currentWordLabel.text = wordGenerated
    }
  }
  
  var strokeViews = [UIView]()
  var keysForWordsFound = [String : [String]]()
  
  fileprivate func setCellState(key: String, defaultState: Bool = false) {
    guard let cell = cells[key] as? CrosswordCell else { return }
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      if !defaultState {
        cell.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
        cell.layer.cornerRadius = self.cellWidth / 2
      } else {
        cell.layer.transform = CATransform3DIdentity
        cell.layer.cornerRadius = 0
      }
    }, completion: nil)
  }
  
  // Generate stroke after word is successfully found
  fileprivate func drawCurves(_ startKey: String, _ endKey: String) {
    if let initialView = cells[startKey], let destinationView = cells[endKey] {
      var startPoint = CGPoint(x: initialView.center.x, y: initialView.center.y)
      var endPoint = CGPoint(x: destinationView.center.x, y: destinationView.center.y)
      
      if UIDevice.current.orientation.isPortrait {
        startPoint.x += view.safeAreaInsets.left
        endPoint.x += view.safeAreaInsets.left
      } else {
        startPoint.y += view.safeAreaInsets.top
        endPoint.y += view.safeAreaInsets.top
      }
      
      let path = UIBezierPath()
      let shapeLayer = CAShapeLayer()
      
      let strokeView = UIView()
      
      shapeLayer.strokeColor = UIColor(red: 0.96, green: 0.00, blue: 0.34, alpha: 0.75).cgColor
      shapeLayer.lineWidth = (cellWidth * 0.8)
      strokeView.layer.addSublayer(shapeLayer)
      
      path.move(to: startPoint)
      path.addLine(to: endPoint)
      shapeLayer.path = path.cgPath
      
      strokeViews.append(strokeView)
      crosswordCollectionView.addSubview(strokeView)
      crosswordCollectionView.sendSubviewToBack(strokeView)
    }
  }
  
  func removeStrokeViews() {
    for strokeView in strokeViews {
      strokeView.removeFromSuperview()
    }
    strokeViews = []
  }
  
  func regenerateStrokeViews() {
    for (_, values) in keysForWordsFound {
      for value in values {
        setCellState(key: value)
      }
      drawCurves(values[0], values[values.count - 1])
    }
  }
  
  @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: crosswordCollectionView)
    
    let column = Int(location.x / cellWidth)
    let row = Int(location.y / cellWidth)
    
    let key = "\(row)|\(column)"
    
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
        
        
        
        if keysUsed.contains(key) { return }
        
        setCellState(key: key, defaultState: true)
        
      }
      break
    case .ended:
      // print("ended")
      
      if wordsFound.contains(wordGenerated) { return }
      
      if !words.contains(wordGenerated) {
        for value in currentValues {
          
          if keysUsed.contains(value) { continue }
          
          setCellState(key: value, defaultState: true)
        }
        return
      } else {
        for value in currentValues {
          keysUsed.append(value)
        }
      }
      
      keysForWordsFound[wordGenerated] = currentValues
      
      wordsFound.append(wordGenerated)
      
      drawCurves(currentValues[0], currentValues[currentValues.count - 1])
      break
    case .cancelled:
      print("cancelled")
      break
    default:
      print("unknow gesture state")
    }
    setCellState(key: key)
    
  }
  
  func getCurrentWord() -> String {
    var word = ""
    for key in currentValues {
      guard let cell = cells[key] as? CrosswordCell else { return "" }
      word += cell.charLabel.text!
    }
    return word
  }
  
  func confettiWithColor(color: UIColor) -> CAEmitterCell {
    let confetti = CAEmitterCell()
    confetti.scale = 0.1
    confetti.birthRate = 20.0
    confetti.lifetime = 15
    confetti.lifetimeRange = 10
    confetti.color = color.cgColor
    confetti.velocity = CGFloat(getRandomVelocity())
    confetti.velocityRange = 0
    confetti.emissionLongitude = CGFloat(Double.pi)
    confetti.emissionRange = CGFloat(Double.pi)
    confetti.spin = 3.5
    confetti.spinRange = 0
    confetti.scaleRange = 0.25
    confetti.scaleSpeed = CGFloat(-0.1)
    confetti.contents = getNextImage(i: getRandomNumber())
    confetti.alphaSpeed = -1.0 / 14.0
    
    return confetti
  }
  
  func startConfettiAnimation() {
    emitter.removeFromSuperlayer()
    
    emitter.emitterPosition = CGPoint(x: self.view.frame.size.width / 2, y: -10)
    emitter.emitterShape = CAEmitterLayerEmitterShape.line
    emitter.emitterSize = CGSize(width: self.view.frame.size.width, height: 2.0)
    emitter.renderMode = CAEmitterLayerRenderMode.additive
    
    let cells = colors.map({
      return confettiWithColor(color: $0)
    })
    
    emitter.emitterCells = cells
    
    emitter.birthRate = 1.0
    
    view.layer.addSublayer(emitter)
    animating = true
  }
  
  func stopConfettiAnimation(clear: Bool = false) {
    if clear {
      emitter.removeFromSuperlayer()
    } else {
      emitter.birthRate = 0
    }
    
    animating = false
  }
  
  private func getRandomVelocity() -> Int {
    return velocities[getRandomNumber()]
  }
  
  private func getRandomNumber() -> Int {
    return Int(arc4random_uniform(4))
  }
  
  private func getNextColor(i:Int) -> CGColor {
    if i <= 4 {
      return colors[0].cgColor
    } else if i <= 8 {
      return colors[1].cgColor
    } else if i <= 12 {
      return colors[2].cgColor
    } else {
      return colors[3].cgColor
    }
  }
  
  private func getNextImage(i:Int) -> CGImage {
    return images[i % 4].cgImage!
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
    return CGSize(width: cellWidth, height: cellWidth)
  }
  
}
