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
   
   @IBOutlet weak var questionTextViewHeightConstraint: NSLayoutConstraint!
   
   @IBOutlet weak var tableView: UITableView!
    
   weak var delegate: AddQuestionViewControllerDelegate?
   
    let ID = DataManager.ID!
    
    var questionIndex: Int? = nil
    
    var question: MCQ? = nil {
        
        didSet {
            answerChoices = question!.answerChoices
            correctAnswers = question!.correctAnswers
            text = question!.question
        }
        
    }
    
    let letters = ["A", "B", "C", "D", "E", "F"]
    
   var answerChoices: [String] = [""]
    
    var correctAnswers: [Int] = []
    
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       tableView.dataSource = self
       questionTextView.delegate = self
       tableView.register(UINib(nibName: "AddAnswerCell", bundle: nil), forCellReuseIdentifier: "AddAnswerCell")
       tableView.register(UINib(nibName: "DeleteQuestionCell", bundle: nil), forCellReuseIdentifier: "DeleteQuestionCell")
        
       questionTextView.text = text
       questionTextView.isScrollEnabled = false
       
       tableView.reloadData()
        // Do any additional setup after loading the view.
    }
   
   override func viewDidLayoutSubviews() {
      // Force layout of question text view to set initial height
      textViewDidChange(questionTextView)
   }
    
    func addQuestion(completion: @escaping (_ error: String?, _ question: Int?) -> Void) {
        
 
       if noQuestion() || noAnswerSelected() || noAnswerChoice() {
           completion("missingFields", questionIndex)
           return
       }

        let index = questionIndex!
    
        dm.addQuestionToRoom(roomID: ID, question: text, answerChoices: answerChoices, correctAnswers: correctAnswers, index: index, time: Date().timeIntervalSince1970) {
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
       var answers: [String] = []
       if answerChoices.count != 6 {
          cells.remove(at: cells.count-2)
       }
       cells.remove(at: cells.count-1)
        
       for i in 0...cells.count-1 {
          var c = cells[i] as! EditAnswerCell
          //if c.answerTextField.text! != "" {
          answers.append(c.answerTextView.text ?? "")
          //}
       }
       return answers
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
   
   func isEmpty() -> Bool {
      return text == "" && correctAnswers.isEmpty && answerChoices.count == 1 && answerChoices[0] == ""
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
   
   @objc func deleteButtonAction(sender: UIButton) {
      //Deletes self
      delegate?.deleteAddQuestionViewController(self)
   }
        
}



    
extension AddQuestionViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       if answerChoices.count == 6 {
          print(answerChoices)
          return answerChoices.count + 1
       }
       return answerChoices.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let index = indexPath.row
        
       if indexPath.row == tableView.numberOfRows(inSection: 0) - 2 && answerChoices.count != 6 {
          print("Add answer cell")
          print(indexPath.row)
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAnswerCell", for: indexPath) as! AddAnswerCell
            cell.addAnswerButton.addTarget(self, action: #selector(addAnswerButtonAction(sender:)), for: .touchUpInside)
            
            return cell
            
        } else if (indexPath.row == tableView.numberOfRows(inSection: 0) - 1) {
           let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteQuestionCell", for: indexPath) as! DeleteQuestionCell
           cell.deleteButton.addTarget(self, action: #selector(deleteButtonAction(sender:)), for: .touchUpInside)
           
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
   
   // Calculate the new height based on the question text
   func textViewDidChange(_ textView: UITextView) {
      let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: 999.0))
      questionTextViewHeightConstraint.constant = size.height
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
      answerTextView.isScrollEnabled = false
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
   @IBOutlet weak var buttonBackground: UIView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       buttonBackground.layer.cornerRadius = 10.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

protocol AddQuestionViewControllerDelegate: AnyObject {
   func deleteAddQuestionViewController(_ viewController: AddQuestionViewController)
}

class DeleteQuestionCell: UITableViewCell {
   
   @IBOutlet weak var deleteButton: UIButton!
   @IBOutlet weak var buttonBackground: UIView!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       buttonBackground.layer.cornerRadius = 10.0
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


