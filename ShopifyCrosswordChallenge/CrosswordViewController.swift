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
  
  // MARK:- Declarations
  @IBOutlet weak var currentWordLabel: CurrentWordLabel!
  @IBOutlet weak var crosswordCollectionView: UICollectionView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var wordsCollectionView: WordsCollectionView!
  
  // Crossword generator
  var wordSearch: WordSearchGenerator!
  
  // Width calculated dynamically based on orientation
  var dynamicWidth: CGFloat = 0
  
  // Save words already found
  var wordsFound = [String]() {
    didSet {
      // Update score label when a new word is found
      scoreLabel.text = "Score: \(wordsFound.count)/\(wordSearch.words.count)"
      
      wordsCollectionView.wordsFound = wordsFound
      
      if wordsFound.count == Constants.words.count {
        completeGame()
      }
    }
  }
  
  // Store key to cell dictionary
  var cellFromKey = [String: UIView]()
  
  // Store keys of cells of words already found
  var keysFound = [String]()
  
  // Current keys for gesture
  var currentKeysForGestureState = [String]() {
    didSet {
      currentWordLabel.text = getWordGenerated()
    }
  }
  
  var wordToListOfKeys = [String : [String]]()
  
  var strokeViews = [UIView]()
  
  var gameCompletionUI: GameCompletionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupCrosswordCollectionView()
    populateCrossword()
    setupWordLabel()
    setupScoreLabel()
    setupWordsCollectionView()
    setupGameCompletionUI()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    calculateWidthAndUpdateConstraints()
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
      self.calculateWidthAndUpdateConstraints()
      self.animateCellsForWordsFound()
    }
  }
  
  // MARK:- Setup UI
  
  func setupCrosswordCollectionView() {
    crosswordCollectionView.register(CrosswordCell.self, forCellWithReuseIdentifier: cellIdentifier)
    crosswordCollectionView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleCrosswordSwipeGesture(gesture:))))
    crosswordCollectionView.backgroundColor = .clear
    crosswordCollectionView.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setupWordLabel() {
    currentWordLabel.layer.borderColor = UIColor.darkGray.cgColor
    currentWordLabel.layer.borderWidth = 0.8
    currentWordLabel.translatesAutoresizingMaskIntoConstraints = false
  }
  
  func setupScoreLabel() {
    scoreLabel.text = "Score: \(wordsFound.count)/\(wordSearch.words.count)"
  }
  
  func setupWordsCollectionView() {
    wordsCollectionView.words = wordSearch.words.reversed()
  }
  
  func setupGameCompletionUI() {
    gameCompletionUI = GameCompletionView(frame: view.bounds)
    view.addSubview(gameCompletionUI)
    gameCompletionUI.delegate = self
  }
  
  // MARK:- Methods
  
  // Dynamically calculate width of collection view based on orientation
  fileprivate func calculateWidthAndUpdateConstraints() {
    if UIDevice.current.orientation.isPortrait {
      dynamicWidth = containerView.frame.width - 32
    } else if UIDevice.current.orientation.isLandscape {
      let del: CGFloat = currentWordLabel.frame.height + 16 + 8
      dynamicWidth = containerView.frame.height - del
    }
    
    crosswordCollectionView.constraints.forEach { (constraint) in
      if constraint.firstAttribute == .width || constraint.firstAttribute == .height {
        constraint.constant = dynamicWidth
      }
    }
    crosswordCollectionView.reloadData()
    
    currentWordLabel.constraints.forEach { (constraint) in
      if constraint.firstAttribute == .width {
        constraint.constant = dynamicWidth
      }
    }
  }
  
  // Initialize grid with a set of words
  func populateCrossword() {
    wordSearch = WordSearchGenerator(10, 10, Constants.words)
    wordSearch.generateGrid()
  }
  
  func storeKeyForCurrentGestureAndAnimateCell(_ key: String) {
    if !currentKeysForGestureState.contains(key) {
      currentKeysForGestureState.append(key)
    }
    updateCellState(key)
  }
  
  func updateCellState(_ key: String, identity: Bool = false) {
    guard let cell = cellFromKey[key] as? CrosswordCell else { return }
    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
      cell.layer.transform = CATransform3DIdentity
      cell.layer.cornerRadius = 0
      if !identity {
        cell.layer.cornerRadius = (self.dynamicWidth / 10) / 2
        cell.layer.transform = CATransform3DMakeScale(0.8, 0.8, 0.8)
      }
    }, completion: nil)
  }
  
  @objc func handleCrosswordSwipeGesture(gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: crosswordCollectionView)
    
    // Get the row and column index
    let column = Int(location.x / (dynamicWidth / 10))
    let row = Int(location.y / (dynamicWidth / 10))
    
    let key = "\(row)|\(column)"
    
    if (column < 0 || column > 9 || row < 0 || row > 9) {
      gesture.state = .ended
    }
    
    switch gesture.state {
    case .began:
      currentKeysForGestureState = []
      storeKeyForCurrentGestureAndAnimateCell(key)
      break
    case .changed:
      storeKeyForCurrentGestureAndAnimateCell(key)
      break
    case .ended:
      if wordsFound.contains(getWordGenerated()) {
        return
      }
      
      if !Constants.words.contains(getWordGenerated()) {
        for key in currentKeysForGestureState {
          updateCellState(key, identity: true)
        }
      } else {
        for key in currentKeysForGestureState {
          keysFound.append(key)
        }
        wordsFound.append(getWordGenerated())
        wordToListOfKeys[getWordGenerated()] = currentKeysForGestureState
        drawCurve(startKey: currentKeysForGestureState[0], endKey: currentKeysForGestureState[currentKeysForGestureState.count - 1])
      }
      break
    default:
      break
    }
    
  }
  
  func getWordGenerated() -> String {
    var word = ""
    for key in currentKeysForGestureState {
      guard let cell = cellFromKey[key] as? CrosswordCell else { return "" }
      word += cell.charLabel.text!
    }
    return word
  }
  
  func animateCellsForWordsFound() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
      for key in self.keysFound {
        self.updateCellState(key)
      }
      self.removeStrokeView()
      self.regenerateStrokeViews()
      self.wordsCollectionView.reloadData()
    })
  }
  
  func removeStrokeView() {
    for view in strokeViews {
      view.removeFromSuperview()
    }
  }
  
  func regenerateStrokeViews() {
    for (_, value) in wordToListOfKeys {
      drawCurve(startKey: value[0], endKey: value[value.count - 1])
    }
  }
  
  func drawCurve(startKey: String, endKey: String) {
    if let startView = cellFromKey[startKey], let endView = cellFromKey[endKey] {
      var startPoint = CGPoint(x: startView.center.x, y: startView.center.y)
      var endPoint = CGPoint(x: endView.center.x, y: endView.center.y)
      
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
      shapeLayer.lineWidth = ((dynamicWidth / 10) * 0.8)
      strokeView.layer.addSublayer(shapeLayer)
      
      path.move(to: startPoint)
      path.addLine(to: endPoint)
      shapeLayer.path = path.cgPath
      
      strokeViews.append(strokeView)
      crosswordCollectionView.addSubview(strokeView)
      crosswordCollectionView.sendSubviewToBack(strokeView)
    }
  }
  
  func completeGame() {
    gameCompletionUI.showView()
  }
  
  func resetState() {
    populateCrossword()
    wordsFound = []
    
    for key in keysFound {
      updateCellState(key, identity: true)
    }
    
    keysFound = []
    wordToListOfKeys = [:]
    removeStrokeView()
    currentWordLabel.text = " "
    
    crosswordCollectionView.reloadData()
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
    cellFromKey[key] = cell
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: dynamicWidth / 10, height: dynamicWidth / 10)
  }
  
}
