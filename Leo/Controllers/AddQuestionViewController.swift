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
    
    @IBOutlet weak var tableView: UITableView!
    
    let roomID = User.roomID
    
    var questionIndex: Int? = nil
    
    var question: MCQ? = nil {
        
        didSet {
            answerChoices = question!.answerChoices
            correctAnswers = question!.correctAnswers
            q = question!.question
        }
        
    }
    
    
    var numAnswers: Int = 2
    
    let letters = ["A", "B", "C", "D", "E", "F"]
    
    var answerChoices = [""]
    
    var correctAnswers: [Int] = []
    
    var q = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "AddAnswerCell", bundle: nil), forCellReuseIdentifier: "AddAnswerCell")
        
        questionTextField.text = q
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func addQuestion(completion: @escaping (_ error: Bool?, _ question: Int?) -> Void) {
            
//        if noQuestion() || missingAnswerChoices() || noAnswerSelected() {
//
//            completion(true, questionIndex)
//
//        }
            
//            let q = questionTextField.text!
//
//            var correct: [Int] = []
//
//            if optionACorrect.isOn {
//                correct.append(0)
//            }
//            if optionBCorrect.isOn {
//                correct.append(1)
//            }
//            if optionCCorrect.isOn {
//                correct.append(2)
//            }
//            if optionDCorrect.isOn {
//                correct.append(3)
//            }
//
//            let newQ = MCQ(question: q, answerChoices: [optionA.text!, optionB.text!, optionC.text!, optionD.text!], correctAnswers: correct, results: [0, 0, 0, 0])
//
            
            
            if let index = questionIndex {
                
//                dm.addQuestionToRoom(roomID: roomID, question: newQ.question, answerChoices: newQ.answerChoices, correctAnswers: newQ.correctAnswers, index: index, time: Date().timeIntervalSince1970) {
//
//                    completion(false, self.questionIndex)
//
//                }
               
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
        
//    func missingAnswerChoices() -> Bool {
//
//        return optionA.text == "" || optionB.text == "" || optionC.text == "" || optionD.text == ""
//
//    }
//
//    func noQuestion () -> Bool {
//
//        return questionTextField.text?.trimmingCharacters(in: [" "]) == ""
//
//    }
//
//    func noAnswerSelected () -> Bool {
//
//        return !optionACorrect.isOn && !optionBCorrect.isOn && !optionCCorrect.isOn && !optionDCorrect.isOn
//    }
//
//    func resetFields() {
//
//        questionTextField.text = ""
//
//        optionA.text = ""
//        optionB.text = ""
//        optionC.text = ""
//        optionD.text = ""
//
//        optionACorrect.isOn = false
//        optionBCorrect.isOn = false
//        optionCCorrect.isOn = false
//        optionDCorrect.isOn = false
//    }
    
    
    
    @objc func addAnswerButtonAction(sender: UIButton) {
        
        print("Add answer button clicked")
        answerChoices.append("")
        tableView.reloadData()
        
    }
        
        
}


    
extension AddQuestionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return answerChoices.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
        if indexPath.row == tableView.numberOfRows(inSection: 0) - 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAnswerCell", for: indexPath) as! AddAnswerCell
            cell.addAnswerButton.addTarget(self, action: #selector(addAnswerButtonAction(sender:)), for: .touchUpInside)
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditAnswerCell", for: indexPath) as! EditAnswerCell
            cell.answerTextField.text = question?.answerChoices[index] ?? ""
            cell.answerPrefix.text = letters[index]
            for i in correctAnswers {
                if index == i {
                    
                    cell.answerTypeButton.imageView?.tintColor = UIColor(named: "CorrectColor")
                    cell.answerTypeButton.imageView?.image = UIImage(systemName: "checkmark")
                } else {
                    cell.answerTypeButton.imageView?.tintColor = UIColor(named: "IncorrectColor")
                    cell.answerTypeButton.imageView?.image = UIImage(systemName: "checkmark")
                }
            }
            
            return cell
        }
        
        
        
    }
    
    
    
    
}


class EditAnswerCell: UITableViewCell {
    
    @IBOutlet weak var answerPrefix: UILabel!
    @IBOutlet weak var answerTextField: UITextField!
    @IBOutlet weak var answerTypeButton: UIButton!
    
    
}

class AddAnswerCell: UITableViewCell {

    @IBOutlet weak var addAnswerButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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


