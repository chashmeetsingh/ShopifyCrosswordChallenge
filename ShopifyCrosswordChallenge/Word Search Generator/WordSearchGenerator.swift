//
//  CrosswordGenerator.swift
//  ShopifyCrosswordChallenge
//
//  Created by Chashmeet on 25/04/19.
//  Copyright © 2019 Chashmeet Singh. All rights reserved.
//

// Reference https://github.com/twostraws/SwiftOnSundays/tree/master/006%20Wordsearch
// Swift on Sundays by Paul Hudson (@twostraws)

import Foundation

struct Word {
  var text: String
}

class Label {
  var letter: Character = "-"
}

class WordSearchGenerator {
  var words = [Word]()
  
  var numberOfRows = 10
  var numberOfColumns = 10
  
  var crossword = [[Label]]()
  var difficulty = Difficulty.medium
  
  // Save all possible uppercase letters
  let allLetters = (65...90).map { Character(Unicode.Scalar($0)) }
  
  // Initialize with number of rows and columns and a list of words
  init(_ rows: Int, _ columns: Int, _ wordList: [String]) {
    self.numberOfRows = rows
    self.numberOfColumns = columns
    
    self.words = []
    for word in wordList.sorted(by: {$0.count > $1.count}) {
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
  
  // Populate with random words
  fileprivate func fillGaps() {
    for column in crossword {
      for label in column {
        if label.letter == "-" {
          label.letter = allLetters.randomElement()!
        }
      }
    }
  }
  
  // Debug grid by printing
  func printGrid() {
    for column in crossword {
      for row in column {
        print(row.letter, terminator: " ")
      }
      print()
    }
  }
  
  // Get the contents of the grid
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
  
  // Try placing a word based on given direction
  func tryPlacing(_ word: String, direction: (x: Int, y: Int)) -> Bool {
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
  
  // Try placing word based on all possible direction
  func place(_ word: Word) -> Bool {
    let formatterWord = word.text.replacingOccurrences(of: " ", with: "").uppercased()
    
    return difficulty.directions.contains {
      tryPlacing(formatterWord, direction: $0.movement)
    }
  }
  
  func placeWords() -> [Word] {
    return words.shuffled().filter(place)
  }
  
}
