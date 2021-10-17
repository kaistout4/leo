//
//  RoomManagerViewController.swift
//  Leo
//
//  Created by Kai Stout on 7/10/21.
//

import UIKit
import Firebase

class AddQuestionViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    let dm = DataManager()
    
    @IBOutlet weak var questionTextField: UITextField!
    @IBOutlet weak var optionA: UITextField!
    @IBOutlet weak var optionB: UITextField!
    @IBOutlet weak var optionC: UITextField!
    @IBOutlet weak var optionD: UITextField!
    
    @IBOutlet weak var optionACorrect: UISwitch!
    @IBOutlet weak var optionBCorrect: UISwitch!
    @IBOutlet weak var optionCCorrect: UISwitch!
    @IBOutlet weak var optionDCorrect: UISwitch!
    
    let roomID = User.roomID
    
    var state: String = "idle"
    
    var questionIndex: Int? = nil
    
    var question: MCQ? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       resetFields()
        
        if let question = question {
            
            loadQuestion()
        }
        // Do any additional setup after loading the view.
    }
    
    
    func loadQuestion() {
        
        questionTextField.text = question?.question
        
        optionA.text = question!.answerChoices[0]
        optionB.text = question!.answerChoices[1]
        optionC.text = question!.answerChoices[2]
        optionD.text = question!.answerChoices[3]
        
        for i in question!.correctAnswers {
            
            if i == 0 {
                optionACorrect.isOn = true
            }
            if i == 1 {
                optionBCorrect.isOn = true
            }
            if i == 2 {
                optionCCorrect.isOn = true
            }
            if i == 3 {
                optionDCorrect.isOn = true
            }
            
        }
        
    }
    
    func addQuestion(completion: @escaping (_ error: Bool?, _ question: Int?) -> Void) {
            
        if noQuestion() || missingAnswerChoices() || noAnswerSelected() {
            
            completion(true, questionIndex)
            
        }
            
            let q = questionTextField.text!
            
            var correct: [Int] = []
        
            if optionACorrect.isOn {
                correct.append(0)
            }
            if optionBCorrect.isOn {
                correct.append(1)
            }
            if optionCCorrect.isOn {
                correct.append(2)
            }
            if optionDCorrect.isOn {
                correct.append(3)
            }
            
            let newQ = MCQ(question: q, answerChoices: [optionA.text!, optionB.text!, optionC.text!, optionD.text!], correctAnswers: correct, results: [0, 0, 0, 0])
            
            
            
            if let index = questionIndex {
                
                dm.addQuestionToRoom(roomID: roomID, question: newQ.question, answerChoices: newQ.answerChoices, correctAnswers: newQ.correctAnswers, index: index, time: Date().timeIntervalSince1970) {
                    
                    completion(false, self.questionIndex)
                    
                }
               
            }
            
//            let alert = UIAlertController(title: "Question Added", message: "", preferredStyle: .alert)
//
//            let action = UIAlertAction(title: "Ok", style: .default) { (action) in
//
//
//            alert.addAction(action)
//
//            self.present(alert, animated: true, completion: nil)
            
    }
        
    func missingAnswerChoices() -> Bool {
        
        return optionA.text == "" || optionB.text == "" || optionC.text == "" || optionD.text == ""
        
    }
    
    func noQuestion () -> Bool {
    
        return questionTextField.text?.trimmingCharacters(in: [" "]) == ""
        
    }
    
    func noAnswerSelected () -> Bool {
        
        return !optionACorrect.isOn && !optionBCorrect.isOn && !optionCCorrect.isOn && !optionDCorrect.isOn
    }
    
    func resetFields() {
        
        questionTextField.text = ""
        
        optionA.text = ""
        optionB.text = ""
        optionC.text = ""
        optionD.text = ""
        
        optionACorrect.isOn = false
        optionBCorrect.isOn = false
        optionCCorrect.isOn = false
        optionDCorrect.isOn = false
    }
    
        
        
        
}
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


