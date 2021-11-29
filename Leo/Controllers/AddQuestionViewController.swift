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
           questionId = question!.id
            answerChoices = question!.answerChoices
            correctAnswers = question!.correctAnswers
            text = question!.question
        }
        
    }
    
    let letters = ["A", "B", "C", "D", "E", "F"]
    
   var questionId: String = UUID().uuidString
   
   var answerChoices: [String] = [""]
    
    var correctAnswers: [Int] = []
    
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
       let notificationCenter = NotificationCenter.default
       notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
       notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
       
       tableView.dataSource = self
       questionTextView.delegate = self
       
       tableView.register(UINib(nibName: "AddAnswerCell", bundle: nil), forCellReuseIdentifier: "AddAnswerCell")
       tableView.register(UINib(nibName: "DeleteQuestionCell", bundle: nil), forCellReuseIdentifier: "DeleteQuestionCell")
      
       if text == "" {
          questionTextView.text = "Type question here"
          questionTextView.textColor = UIColor.secondaryLabel
       } else {
          questionTextView.text = text
       }
       questionTextView.isScrollEnabled = false
       
       tableView.reloadData()
        // Do any additional setup after loading the view.
    }
   
   @objc func adjustForKeyboard(notification: Notification) {
       guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

       let keyboardScreenEndFrame = keyboardValue.cgRectValue
       let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

       if notification.name == UIResponder.keyboardWillHideNotification {
           tableView.contentInset = .zero
       } else {
           tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
       }

       tableView.scrollIndicatorInsets = tableView.contentInset
       
   }
   
   override func viewDidLayoutSubviews() {
      // Force layout of question text view to set initial height
      textViewDidChange(questionTextView)
   }
    
    func addQuestion(completion: @escaping (_ error: String?) -> Void) {
        
 
       if noQuestion() {
           completion("noQuestion")
           return
       }
       
       if noAnswerChoice() {
          completion("noAnswerChoice")
          return
       }
       
       if noAnswerSelected() {
          completion("noAnswerSelected")
          return
       }

       dm.addQuestionToRoom(id: questionId, index: questionIndex!, roomID: ID, question: text, answerChoices: answerChoices, correctAnswers: correctAnswers, time: Date().timeIntervalSince1970) { [weak self] in
          guard let self = self else { return }
            print("Question successfully added")
          self.question = MCQ(id: self.questionId, index: self.questionIndex!, question: self.text, answerChoices: self.answerChoices, correctAnswers: self.correctAnswers, results: [])
            completion("")

        }
               
    }
   
    func noAnswerChoice() -> Bool {
       
       var noChoice = false
       for i in answerChoices {
          noChoice = i == "" || i == "Type answer here"
       }
       return noChoice

    }

    func noQuestion () -> Bool {

        return text == "" || text == "Type question here"

    }

    func noAnswerSelected () -> Bool {
       return correctAnswers.count == 0
    }
    
    func getAnswerKey() -> [Int] {
        return correctAnswers
    }
   
   func getAnswers(hideBlanks: Bool) -> [String] {
       var cells = tableView.visibleCells
       var answers: [String] = []
       if answerChoices.count != 6 {
          cells.remove(at: cells.count-2)
       }
       cells.remove(at: cells.count-1)
        
       for i in 0...cells.count-1 {
          var c = cells[i] as! EditAnswerCell
          if hideBlanks {
             if c.answerTextView.text != "Type answer here" && !c.answerTextView.text.isEmpty {
                answers.append(c.answerTextView.text ?? "")
             }
          } else {
             answers.append(c.answerTextView.text)
          }
       }
       return answers
    }
   
   func saveData() {
      text = questionTextView.text ?? ""
      if getAnswers(hideBlanks: true).count != 0 {
         answerChoices = getAnswers(hideBlanks: true)
      }
      
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
      return MCQ(id: questionId, index: questionIndex!, question: question ?? "", answerChoices: answers, correctAnswers: key, results: [])
   }
   
   func isEmpty() -> Bool {
      return (text == "" || text == "Type question here") && correctAnswers.isEmpty && answerChoices.count == 1 && answerChoices[0] == ""
   }
    
    @objc func switchAnswerTypeAction(sender: UIButton) {
        
       answerChoices = getAnswers(hideBlanks: false)
       
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
      answerChoices = getAnswers(hideBlanks: false)
       print(answerChoices)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddAnswerCell", for: indexPath) as! AddAnswerCell
            cell.addAnswerButton.addTarget(self, action: #selector(addAnswerButtonAction(sender:)), for: .touchUpInside)
            
            return cell
            
        } else if (indexPath.row == tableView.numberOfRows(inSection: 0) - 1) {
           let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteQuestionCell", for: indexPath) as! DeleteQuestionCell
           cell.deleteButton.addTarget(self, action: #selector(deleteButtonAction(sender:)), for: .touchUpInside)
           
           return cell
       
        } else {
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "EditAnswerCell", for: indexPath) as! EditAnswerCell
           print("Data source \(answerChoices)")
           if answerChoices[index].isEmpty || answerChoices[index] == "Type answer here" {
              cell.answerTextView.text = "Type answer here"
              cell.answerTextView.textColor = UIColor.secondaryLabel
           } else {
              cell.answerTextView.text = answerChoices[index]
              cell.answerTextView.textColor = UIColor.black
           }
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
        cell.delegate = self
         
         return cell
     }
        
    }
    
}

extension AddQuestionViewController: UITextViewDelegate {
   func textViewDidBeginEditing(_ textView: UITextView) {
       if textView.textColor == UIColor.secondaryLabel {
           textView.text = nil
           textView.textColor = UIColor.black
       }
   }
   
   func textViewDidEndEditing(_ textView: UITextView) {
      if textView.text.isEmpty {
         textView.text = "Enter question here"
         textView.textColor = UIColor.secondaryLabel
      }
      
   }
   
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
   
   weak var delegate: EditAnswerCellDelegate?
   
   override func awakeFromNib() {
      answerTextView.delegate = self
      answerTextView.isScrollEnabled = false
      answerBackground.layer.cornerRadius = 10.0
   }
}

extension EditAnswerCell: UITextViewDelegate {
   
   func textViewDidBeginEditing(_ textView: UITextView) {
      print("textViewDidBeginEditing")
      if textView.textColor == UIColor.secondaryLabel {
           textView.text = nil
           textView.textColor = .black
       }
   }
   
   func textViewDidEndEditing(_ textView: UITextView) {
      if textView.text.isEmpty {
         textView.text = "Type answer here"
         textView.textColor = UIColor.secondaryLabel
      }
   }
   
   // Calculate the new height based on the answer text
   func textViewDidChange(_ textView: UITextView) {
      let size = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: 999.0))
      if textView.bounds.height != size.height {
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


