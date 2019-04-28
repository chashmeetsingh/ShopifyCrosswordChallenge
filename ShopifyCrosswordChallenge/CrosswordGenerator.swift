//
//  CrosswordGenerator.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 25/04/19.
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

struct Word {
  var text: String
}

class Label {
  var letter: Character = "-"
}

class WordSearch {
  var words = [Word]()
  
  var numberOfRows = 10
  var numberOfColumns = 10
  
  var crossword = [[Label]]()
  var difficulty = Difficulty.easy
  
  let allLetters = (65...90).map { Character(Unicode.Scalar($0)) }
  
  init(_ rows: Int, _ columns: Int, _ words: [String]) {
    self.numberOfRows = rows
    self.numberOfColumns = columns
    
    self.words = []
    for word in words {
      self.words.append(Word(text: word))
    }
    
  }
  
  func generateGrid() {
    crossword = (0..<numberOfColumns).map { _ in
      (0..<numberOfRows).map { _ in Label() }
    }
    
    _ = placeWords()
    fillGaps()
//    printGrid()
  }
  
  fileprivate func fillGaps() {
    for column in crossword {
      for label in column {
        if label.letter == "-" {
          label.letter = allLetters.randomElement()!
        }
      }
    }
  }
  
  func printGrid() {
    for column in crossword {
      for row in column {
        print(row.letter, terminator: " ")
      }
      print()
    }
  }
  
  func labels(fromX x: Int, fromY y: Int, word: String, direction: (x: Int, y: Int)) -> [Label]? {
    var returnValue = [Label]()
    
    var xPos = x
    var yPos = y
    
    for letter in word {
      let label = crossword[xPos][yPos]
      
      if label.letter == "-" || label.letter == letter {
        returnValue.append(label)
        xPos += direction.x
        yPos += direction.y
      } else {
        return nil
      }
    }
    
    return returnValue
  }
  
  func tryPlace(_ word: String, direction: (x: Int, y: Int)) -> Bool {
    let xLength = direction.x * (word.count - 1)
    let yLength = direction.y * (word.count - 1)
    
    let rows = (0..<numberOfRows).shuffled()
    let columns = (0..<numberOfColumns).shuffled()
    
    for row in rows {
      for col in columns {
        let finalX = col + xLength
        let finalY = row + yLength
        
        if finalX >= 0 && finalX < numberOfRows && finalY >= 0 && finalY < numberOfColumns {
          if let returnValue = labels(fromX: col, fromY: row, word: word, direction: direction) {
            for (index, letter) in word.enumerated() {
              returnValue[index].letter = letter
            }
            return true
          }
        }
      }
    }
    return false
  }
  
  func placeWord(_ word: Word) -> Bool {
    let formatterWord = word.text.replacingOccurrences(of: " ", with: "").uppercased()
    
    return difficulty.directions.contains {
      tryPlace(formatterWord, direction: $0.movement)
    }
  }
  
  func placeWords() -> [Word] {
    return words.shuffled().filter(placeWord)
  }
  
}
