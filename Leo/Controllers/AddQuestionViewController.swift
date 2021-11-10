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
    
   @IBOutlet weak var questionTextView: UITextView!
   
    @IBOutlet weak var tableView: UITableView!
    
    let roomID = User.roomID
    
    var questionIndex: Int? = nil
    
    var question: MCQ? = nil {
        
        didSet {
            answerChoices = question!.answerChoices
            correctAnswers = question!.correctAnswers
            text = question!.question
        }
        
    }
    
    let letters = ["A", "B", "C", "D", "E", "F"]
    
    var answerChoices = [""]
    
    var correctAnswers: [Int] = []
    
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
       questionTextView.delegate = self
        tableView.register(UINib(nibName: "AddAnswerCell", bundle: nil), forCellReuseIdentifier: "AddAnswerCell")
        
       questionTextView.text = text
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    func addQuestion(completion: @escaping (_ error: String?, _ question: Int?) -> Void) {
        
 
       if noQuestion() || noAnswerSelected() || noAnswerChoice() {
           completion("missingFields", questionIndex)
           return
       }

        let index = questionIndex!
    
        dm.addQuestionToRoom(roomID: roomID, question: text, answerChoices: answerChoices, correctAnswers: correctAnswers, index: index, time: Date().timeIntervalSince1970) {
            print("Question successfully added")
           self.question = MCQ(question: self.text, answerChoices: self.answerChoices, correctAnswers: self.correctAnswers, results: [])
            completion("", self.questionIndex)

        }
               
    }
   
    func noAnswerChoice() -> Bool {
       
       var noChoice = false
       for i in answerChoices {
          noChoice = i == ""
          
       }
       return noChoice

    }

    func noQuestion () -> Bool {

        return text == ""

    }

    func noAnswerSelected () -> Bool {
       return correctAnswers.count == 0
    }
    
    func getAnswerKey() -> [Int] {
        return correctAnswers
    }
    
   
    func getAnswers() -> [String] {
        var cells = tableView.visibleCells
        var correct: [String] = []
        cells.remove(at: cells.count-1)
        
        for i in 0...cells.count-1 {
            var c = cells[i] as! EditAnswerCell
            //if c.answerTextField.text! != "" {
            correct.append(c.answerTextView.text!)
            //}
        }
        return correct
    }
   
   func saveData() {
      text = questionTextView.text ?? ""
      answerChoices = getAnswers()
   }
   
   func printQuestion() {
      print(text)
      print(correctAnswers)
      print(answerChoices)
   }
   
   func getQuestion() -> MCQ {
      
      let question = text
      let key = correctAnswers
      let answers = answerChoices
      return MCQ(question: question ?? "", answerChoices: answers, correctAnswers: key, results: [])
   }
    
    @objc func switchAnswerTypeAction(sender: UIButton) {
        
       answerChoices = getAnswers()
       
        let answer = sender.tag
        if correctAnswers.contains(answer) {
            for i in 0...correctAnswers.count-1 {
                if correctAnswers[i] == answer {
                    correctAnswers.remove(at: i)
                    break
                }
            }
        } else {
            correctAnswers.append(answer)
        }
        print(correctAnswers)
        print(answerChoices)
        tableView.reloadData()
        
    }
    @objc func addAnswerButtonAction(sender: UIButton) {
      answerChoices = getAnswers()
       if answerChoices.count == 6 {
          return
       }
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
            
            cell.answerTextView.text = answerChoices[index]
            cell.answerPrefix.text = letters[index]
            cell.answerTypeButton.tag = index
            cell.answerTypeButton.addTarget(self, action: #selector(switchAnswerTypeAction(sender:)), for: .touchUpInside)
            cell.answerTypeButton.setImage(UIImage(systemName: "circle"), for: .normal)
            
            if correctAnswers.contains(index) {
                cell.answerTypeButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
               cell.answerBackground.backgroundColor = UIColor(named: "CorrectColor")
            } else {
               cell.answerBackground.backgroundColor = UIColor(named: "SystemGray6Color")

            }
           cell.answerTypeButton.setNeedsDisplay()
           cell.textViewDidChange(cell.answerTextView)
           cell.delegate = self
            
            return cell
        }
        
    }
    
}

extension AddQuestionViewController: UITextViewDelegate {
   func textViewDidChange(_ textView: UITextView) {
      textView.translatesAutoresizingMaskIntoConstraints = true
      textView.sizeToFit()
      textView.isScrollEnabled = false
   }
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
         print("Swipe to delete")
         answerChoices.remove(at: indexPath.row)
         for i in 0...correctAnswers.count-1 {
            if correctAnswers[i] == indexPath.row {
               print("Removing answer choice " + String(correctAnswers[i]))
               correctAnswers.remove(at: i)
            }
         }
         tableView.deleteRows(at: [indexPath], with: .fade)
      }
   }
}

extension AddQuestionViewController: EditAnswerCellDelegate {
   func editAnswerCellHeightChanged(_ cell: EditAnswerCell) {
      tableView.beginUpdates()
      tableView.endUpdates()
   }
}

protocol EditAnswerCellDelegate: AnyObject {
   func editAnswerCellHeightChanged(_ cell: EditAnswerCell)
}

class EditAnswerCell: UITableViewCell {
   
   @IBOutlet weak var answerPrefix: UILabel!
   @IBOutlet weak var answerTextView: UITextView!
   @IBOutlet weak var answerTypeButton: UIButton!
   @IBOutlet weak var answerBackground: UIView!
   @IBOutlet weak var answerTextViewHeightConstraint: NSLayoutConstraint!
   
   weak var delegate: EditAnswerCellDelegate?
   
   override func awakeFromNib() {
      answerTextView.delegate = self
      answerBackground.layer.cornerRadius = 10.0
   }
   
}

extension EditAnswerCell: UITextViewDelegate {
   
   // Calculate the new height based on the answer text
   func textViewDidChange(_ textView: UITextView) {
      let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: 999.0))
      if answerTextViewHeightConstraint.constant != size.height {
         answerTextViewHeightConstraint.constant = size.height
         delegate?.editAnswerCellHeightChanged(self)
      }
   }
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


