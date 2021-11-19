//
//  RoomViewController.swift
//  Leo
//
//  Created by Kai Stout on 7/10/21.
//

import UIKit
import Firebase

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var teacherCommandView: UIStackView!
    @IBOutlet weak var numResponsesLabel: UILabel!
    
    
    let dm = DataManager()
    
    let db = Firestore.firestore()
    
    var ID = DataManager.ID!
    
    var user = DataManager.user
    
    var question: MCQ? {
        didSet  {
            if isViewLoaded {
                reconfigureCells()
            }
        }
    }
    
    var hideResults = true
    
    var questionIndex: Int?
    
    let letters = ["A", "B", "C", "D", "E", "F"]
    
    var selected: Int = -1 {
        
        didSet {
            
            if isViewLoaded {
                //reconfigureCells()
            }
            
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Updates question and answer labels
        updateQuestion()
        
                
        if (user == "student") {
            hideResults = true
            teacherCommandView.isHidden = true
            
        } else {
            hideResults = false
            monitorForResults()
            
        }
        
        
        tableView.allowsSelection = false
        
        //codeLabel.text = "Code: " + roomID
        // Do any additional setup after loading the view.
        //loadNextQuestion()
    }
    
    func monitorForResults() {
        
        db.collection("rooms").document(ID).collection("questions").document(String(questionIndex!)).addSnapshotListener { documentSnapshot, error in
            
            if let e = error {
                print(e)
                
            } else {
                
                if let doc = documentSnapshot {
                    
                    if let data = doc.data() {
                        
                        if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int, let resultsE = data["resultsE"] as? Int, let resultsF = data["resultsF"] as? Int {
                            
                            self.question = MCQ(question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD, resultsE, resultsF])
                            let numResults = resultsA + resultsB + resultsC + resultsD + resultsE + resultsF
                            self.refreshResults(numResults)
                        }
                    }
                }
            }
        }
    }
    
  
    func refreshResults(_ numResults: Int) {
//        guard isViewLoaded else { return }
//        
//        for cell in tableView.visibleCells {
//            if let cell = cell as? AnswerCell, let indexPath = tableView.indexPath(for: cell) {
//                configureCell(cell: cell, at: indexPath)
//            }
//        }
        
        dm.userCount(roomID: ID) { count in
            self.numResponsesLabel.text = String(numResults) + "/" + String(count) + " responses"
        }
    }
    
    
    
    
    
    
    func configureCell(cell: AnswerCell, at indexPath: IndexPath) {
        
        let index = indexPath.row
        
        let isSelected = index == selected
        cell.answerButton.tag = index
        cell.answerPrefix.text = letters[index]
        
        if let question = question {
            
            cell.answerLabel.text = question.answerChoices[index]
            cell.answerPercentage.isHidden = hideResults
            cell.answerIconImage.isHidden = hideResults
            
            if hideResults {
                cell.answerBackground.backgroundColor = isSelected ?
                UIColor(named: "AccentColor") :
                UIColor(red: 2/255, green: 0/255, blue: 128/255, alpha: 0.04)
                cell.answerLabel.textColor = isSelected ? .white : .black
            } else {
                
                cell.answerButton.isUserInteractionEnabled = false
                
                let results = question.results
                
                let numResults = results[0] + results[1] + results[2] + results[3]
                
                let progress = numResults != 0 ? Float(results[index]) / Float(numResults) : 0.0
                let rounded = Int(round(progress*100))
                cell.answerPercentage.text = String(rounded) + "%"
                
                if isSelected {
                    for i in question.correctAnswers {
                        if index == i {
                            print("Correct")
                            cell.answerIconImage.tintColor = UIColor(named: "CorrectColor")
                            cell.answerIconImage.image = UIImage(systemName: "checkmark")
                            cell.answerBackground.backgroundColor = UIColor(named: "CorrectColor")
                        } else {
                            print("Incorrect")
                            cell.answerIconImage.tintColor = UIColor(named: "IncorrectColor")
                            cell.answerIconImage.image = UIImage(systemName: "xmark")
                            cell.answerBackground.backgroundColor = UIColor(named: "IncorrectColor")
                        }
                    }
                } else {
                    cell.answerIconImage.image = nil
                    for i in question.correctAnswers {
                        if index == i {
                            cell.answerBackground.backgroundColor = UIColor(named: "CorrectColor")
                        }
                    }
                }
                    
                
            }
            
        }
    }
    
    func reconfigureCells() {
        
        for cell in tableView.visibleCells {
            
            if let cell = cell as? AnswerCell {
                
                configureCell(cell: cell, at: tableView.indexPath(for: cell)!)
            }
            
        }
    }
    
    func setSelectedAnswer(selected: Int, animated: Bool) {
        if animated {
            // TODO: re-enable animation
//            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut, .beginFromCurrentState, .allowUserInteraction], animations: {
            self.selected = selected
//            }, completion: nil)
        } else {
            self.selected = selected
        }
    }
    
    
    
    func updateQuestion() {
        
        self.questionTextView.text = question?.question
       
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension QuestionViewController: UITableViewDelegate {
    
}

extension QuestionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (question?.answerChoices.count)!
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AnswerCell", for: indexPath) as! AnswerCell
        cell.answerButton.tag = indexPath.row
        cell.answerButton.addTarget(self, action: #selector(answerButtonAction(sender:)), for: .touchUpInside)
        if selected != -1 {
            cell.answerButton.isUserInteractionEnabled = false
        }
        let size = cell.answerLabel.sizeThatFits(CGSize(width: cell.answerLabel.bounds.width, height: 999.0))
        cell.answerLabelHeightConstraint.constant = size.height
        configureCell(cell: cell, at: indexPath)
        return cell
    }
    
    @objc func answerButtonAction(sender: UIButton) {
        
        setSelectedAnswer(selected: sender.tag, animated: true)
        tableView.reloadData()
    }
    
}

class AnswerCell: UITableViewCell {
    @IBOutlet weak var answerPrefix: UILabel!
    @IBOutlet weak var answerBackground: UIView!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerButton: UIButton!
    @IBOutlet weak var answerPercentage: UILabel!
    @IBOutlet weak var answerIconImage: UIImageView!
    @IBOutlet weak var answerLabelHeightConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        answerBackground.layer.cornerRadius = 10.0
        
    }
}
