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
    
    func addQuestion(completion: @escaping (_ error: String?, _ question: Int?) -> Void) {
        
        print("Adding question")
        if noQuestion() {
            completion("noQuestion", questionIndex)
            return
        }
        
        if noAnswerSelected() {
            completion("noAnswerSelected", questionIndex)
            return
        }
        
        if noAnswerChoice() {
            completion("noAnswerChoice", questionIndex)
            return
        }
        
        let q = questionTextField.text!
        
        let index = questionIndex!
        
        let key = getAnswerKey()
        
        let answers = getAnswers()
                
        dm.addQuestionToRoom(roomID: roomID, question: q, answerChoices: answers, correctAnswers: key, index: index, time: Date().timeIntervalSince1970) {
            print("Questions successfully added")
            completion("", self.questionIndex)

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
            
    
        
    func noAnswerChoice() -> Bool {

        var cells = tableView.visibleCells
        var noChoice = true
        cells.remove(at: cells.count-1)
        
        for i in 0...cells.count-1 {
            var c = cells[i] as! EditAnswerCell
            noChoice = c.answerTextField.text == ""
            
        }
        return noChoice

    }

    func noQuestion () -> Bool {

        return questionTextField.text?.trimmingCharacters(in: [" "]) == ""

    }

    func noAnswerSelected () -> Bool {
        
        var cells = tableView.visibleCells
        print(cells.count)
        var notSelected = true
        cells.remove(at: cells.count-1)
        
        for i in 0...cells.count-1 {
            var c = cells[i] as! EditAnswerCell
            notSelected = c.answerTypeButton.imageView?.tintColor == UIColor(named: "AccentColor")
        }
        return notSelected
    }
    
    func getAnswerKey() -> [Int] {
        var cells = tableView.visibleCells
        var correct: [Int] = []
        cells.remove(at: cells.count-1)
        
        for i in 0...cells.count-1 {
            var c = cells[i] as! EditAnswerCell
            if c.answerTypeButton.imageView?.tintColor == UIColor(named: "CorrectColor")  {
                correct.append(i)
            }
        }
        return correct
    }
    
    func getAnswers() -> [String] {
        var cells = tableView.visibleCells
        var correct: [String] = []
        cells.remove(at: cells.count-1)
        
        for i in 0...cells.count-1 {
            var c = cells[i] as! EditAnswerCell
            //if c.answerTextField.text! != "" {
            correct.append(c.answerTextField.text!)
            //}
        }
        return correct
    }
    
    @objc func switchAnswerTypeAction(sender: UIButton) {
        
        if sender.imageView?.tintColor == UIColor(named: "CorrectColor") {
            sender.imageView?.tintColor = UIColor(named: "AccentColor")
        } else {
            sender.imageView?.tintColor = UIColor(named: "CorrectColor")
        }
    }
    
    @objc func addAnswerButtonAction(sender: UIButton) {
        
        print("Add answer button clicked")
        answerChoices = getAnswers()
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
            
            cell.answerTextField.text = answerChoices[index]
            cell.answerPrefix.text = letters[index]
            cell.answerTypeButton.addTarget(self, action: #selector(switchAnswerTypeAction(sender:)), for: .touchUpInside)
            for i in correctAnswers {
                if index == i {
                    
                    cell.answerTypeButton.imageView?.tintColor = UIColor(named: "CorrectColor")
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


