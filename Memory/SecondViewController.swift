//
//  SecondViewController.swift
//  Memory
//
//  Created by Ella Wickstrom on 5/14/20.
//  Copyright © 2020 Ella Wickstrom. All rights reserved.
//

import UIKit
import AVFoundation

let kDelayBetweenStages = 0.75
let kPlayDuration = 0.4
let kHighScoreKey = "HighScore"

class SecondViewController: UIViewController {
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var highScoreLabel: UILabel!
    
    let userDefault = UserDefaults.standard
    var correctAnswer: [Int] = []
    var userInput: [Int] = []
    var playedIndex = 0
    var inputIndex = 0
    var stage = 0
    
    var highScore: Int {
      get {
        return userDefault.integer(forKey: kHighScoreKey)
      }
      set {
        userDefault.set(newValue, forKey: kHighScoreKey)
        userDefault.synchronize()
        highScoreLabel.text = "\(newValue)"
      }
    }
    
    var isCorrectAnswer: Bool {
      return userInput == correctAnswer
    }
    var timeLimit: Double = 8

    override func viewDidLoad() {
      super.viewDidLoad()
      highScoreLabel.text = "\(highScore)"
      enableAllBtns(false)
    }

    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)

      for v in [startButton] {
        guard let v = v else { return }
        v.layer.cornerRadius = v.frame.height / 2
      }
    }


    @IBAction func startBtnTapped(_ sender: UIButton) {
      enableStartBtn(false)
      newGame()
      nextStage()
    }

    func newGame() {
      correctAnswer.removeAll()
      playedIndex = 0
      stage = 0
      clearUserInputs()
    }

    func clearUserInputs() {
      userInput.removeAll()
      inputIndex = 0
    }

    func nextStage() {
      clearUserInputs()
      correctAnswer.append(Int(arc4random_uniform(4)))
      print("correctAnswer \(correctAnswer)")

      DispatchQueue.main.asyncAfter(deadline: .now() + kDelayBetweenStages) {
        self.stage += 1
        self.timeLimit += 1.5
        print("timeLimit: \(self.timeLimit)")
        self.startButton.setTitle("\(self.stage)", for: .normal)
      }

      playedIndex = 0
      enableAllBtns(false)
      DispatchQueue.main.asyncAfter(deadline: .now() + (kDelayBetweenStages + 1.0)) {
        self.playAnswer()
      }
    }

    func playAnswer() {
      guard playedIndex < correctAnswer.count else {
        playedIndex = 0
        enableAllBtns(true)
        return
      }

      let answer = correctAnswer[playedIndex]
      let btn = btnFromAnswer(answer)
      flashBtn(btn) {_ in
        self.playedIndex += 1
        self.playAnswer()
      }
    }

    func flashBtn(_ btn: UIButton, completion: ((Bool) -> Void)? = nil) {
      btn.alpha = 0.3
      let answer = answerFromBtn(btn)
      UIView.animate(
        withDuration: kPlayDuration,
        delay: 0.0,
        options: .curveEaseInOut,
        animations: {
          btn.alpha = 1
        },
        completion: completion
      )
    }

    @IBAction func btnDown(_ sender: UIButton) {
      let guess = answerFromBtn(sender)
      sender.alpha = 0.3
    }

    @IBAction func btnUp(_ sender: UIButton) {
      let guess = answerFromBtn(sender)
      userInput.append(guess)
      print("userInput: \(userInput)")

      if guess == correctAnswer[inputIndex] {
        inputIndex += 1
        if isCorrectAnswer {
          nextStage()
        }
      } else {
        endGame()
      }

      sender.alpha = 1
    }

    func endGame() {
      enableAllBtns(false)
      enableStartBtn(true)
      timeLimit = 8
      let finalScore = stage - 1
      let highestScore = finalScore > highScore ? finalScore : highScore
      highScore = highestScore
      startButton.setTitle("\(finalScore)", for: .normal)
      print("gameEnd")
    }
    func answerFromBtn(_ from: UIButton) -> Int {
      return from.tag
    }

    func btnFromAnswer(_ from: Int) -> UIButton {
      switch from {
      case 0:
        return button1
      case 1:
        return button2
      case 2:
        return button3
      case 3:
        return button4
      default:
        fatalError()
      }
    }

    func enableAllBtns(_ enabled: Bool) {
      button1.isEnabled = enabled
      button2.isEnabled = enabled
      button3.isEnabled = enabled
      button4.isEnabled = enabled
    }

    func enableStartBtn(_ enabled: Bool) {
      startButton.isEnabled = enabled
    }

    
}
