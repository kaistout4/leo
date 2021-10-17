//
//  RoomViewController.swift
//  Leo
//
//  Created by Kai Stout on 7/10/21.
//

import UIKit
import Firebase

class QuestionViewController: UIViewController {
    
    let dm = DataManager()
    
    let db = Firestore.firestore()
    
    let roomID = User.roomID
    
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var answerChoice1: UIButton!
    @IBOutlet weak var answerChoice2: UIButton!
    @IBOutlet weak var answerChoice3: UIButton!
    @IBOutlet weak var answerChoice4: UIButton!
    
    @IBOutlet weak var answerChoice1Results: UIProgressView!
    @IBOutlet weak var answerChoice2Results: UIProgressView!
    @IBOutlet weak var answerChoice3Results: UIProgressView!
    @IBOutlet weak var answerChoice4Results: UIProgressView!
    
    @IBOutlet weak var answerChoice1Percent: UILabel!
    @IBOutlet weak var answerChoice2Percent: UILabel!
    @IBOutlet weak var answerChoice3Percent: UILabel!
    @IBOutlet weak var answerChoice4Percent: UILabel!
    
    @IBOutlet weak var answerChoice1Image: UIImageView!
    @IBOutlet weak var answerChoice2Image: UIImageView!
    @IBOutlet weak var answerChoice3Image: UIImageView!
    @IBOutlet weak var answerChoice4Image: UIImageView!
    
    
    @IBOutlet weak var teacherCommandView: UIStackView!
    @IBOutlet weak var numResponsesLabel: UILabel!
    
    
    let user = User.user
    
    var question: MCQ?
    
    var questionIndex: Int?
    
    var selected: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Updates question and answer labels
        updateQuestion()
        
        if (user == "student") {
            
            print("Student")
            
            hideResultsUIItems()
            
            teacherCommandView.isHidden = true
            
            
            
        } else {
            
            print("Teacher")
            showResultsUIItems()
            teacherCommandView.isHidden = false
            monitorForResults()
            
        }
        
        
        
    
        
        
        //codeLabel.text = "Code: " + roomID
        // Do any additional setup after loading the view.
        //loadNextQuestion()
    }
    
    func monitorForResults() {
        
        print(questionIndex)
        db.collection("rooms").document(roomID).collection("questions").document(String(questionIndex!)).addSnapshotListener { documentSnapshot, error in
            
            if let e = error {
                print(e)
                
            } else {
                
                if let doc = documentSnapshot {
                    
                    if let data = doc.data() {
                        
                        if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int {
                            
                            self.question = MCQ(question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD])
                            self.refreshResults()
                        }
                    
                        
                    }
                    
                    
                    
                    
                    
                }
                
            }
            
            
            
        }
        
    }
    
  
    
    func refreshResults() {
            
        if let question = self.question {
                
            
            let results = question.results
            print(results)
            let numResults = results[0] + results[1] + results[2] + results[3]
            
            let correctAnswers = question.correctAnswers
            
            self.updateCheckBoxes(correctAnswers)
            
            if numResults != 0 {
                
                let progress1 = Float(results[0]) / Float(numResults)
                self.answerChoice1Results.progress = progress1
                print(progress1)
                
                let progress2 = Float(results[1]) / Float(numResults)
                self.answerChoice2Results.progress = progress2
                print(progress2)
                
                let progress3 = Float(results[2]) / Float(numResults)
                self.answerChoice3Results.progress = progress3
                print(progress3)
                
                let progress4 = Float(results[3]) / Float(numResults)
                self.answerChoice4Results.progress = progress1
                print(progress4)
                
                let rounded1 = round(progress1*100)
                let rounded2 = round(progress2*100)
                let rounded3 = round(progress3*100)
                let rounded4 = round(progress4*100)
                
                self.answerChoice1Percent.text = String(Int(rounded1)) + "%"
                self.answerChoice2Percent.text = String(Int(rounded2)) + "%"
                self.answerChoice3Percent.text = String(Int(rounded3)) + "%"
                self.answerChoice4Percent.text = String(Int(rounded4)) + "%"
                
                dm.userCount(roomID: roomID) { count in
                    
                    self.numResponsesLabel.text = String(numResults) + "/" + String(count) + " responses"
                }
                
            
                self.showResultsUIItems()
                
            }
            
                
        }
      
        
        
        
        
        
    }
    
    func showResultsUIItems() {
        
        answerChoice1Results.isHidden = false
        answerChoice2Results.isHidden = false
        answerChoice3Results.isHidden = false
        answerChoice4Results.isHidden = false
        
        answerChoice1Percent.isHidden = false
        answerChoice2Percent.isHidden = false
        answerChoice3Percent.isHidden = false
        answerChoice4Percent.isHidden = false
        
        answerChoice1Image.isHidden = false
        answerChoice2Image.isHidden = false
        answerChoice3Image.isHidden = false
        answerChoice4Image.isHidden = false
    }
    
    func hideResultsUIItems() {
        
        answerChoice1Results.isHidden = true
        answerChoice2Results.isHidden = true
        answerChoice3Results.isHidden = true
        answerChoice4Results.isHidden = true
        
        answerChoice1Percent.isHidden = true
        answerChoice2Percent.isHidden = true
        answerChoice3Percent.isHidden = true
        answerChoice4Percent.isHidden = true
        
        answerChoice1Image.isHidden = true
        answerChoice2Image.isHidden = true
        answerChoice3Image.isHidden = true
        answerChoice4Image.isHidden = true
    }
    
    func updateCheckBoxes(_ correctAnswers: [Int]) {
    
        
        if (correctAnswers.contains(0)) {
            
            answerChoice1Image.image = UIImage(systemName: "checkmark.circle.fill")
            
        } else {
            
            answerChoice1Image.image = UIImage(systemName: "xmark.circle.fill")
            
        }
        
        if (correctAnswers.contains(1)) {
            
            answerChoice2Image.image = UIImage(systemName: "checkmark.circle.fill")
           
        } else {
            
            answerChoice2Image.image = UIImage(systemName: "xmark.circle.fill")
            
        }
        
        if (correctAnswers.contains(2)) {
            
            answerChoice3Image.image = UIImage(systemName: "checkmark.circle.fill")
            print("Image 3 checkbox : correct")
            
        } else {
            
            answerChoice3Image.image = UIImage(systemName: "xmark.circle.fill")
            
        }
        
        if (correctAnswers.contains(3)) {
            
            answerChoice4Image.image = UIImage(systemName: "checkmark.circle.fill")
            print("Image 4 checkbox : correct")
            
        } else {
            
            answerChoice4Image.image = UIImage(systemName: "xmark.circle.fill")
            
        }
        
        
    }
    
    
    
    @IBAction func answerChoice1Selected(_ sender: UIButton) {
        
        selected = 0
        
        dm.updateVote(roomID: roomID, questionIndex: questionIndex!, answerIndex: 0) {
            
            
        }
    }
    
    @IBAction func answerChoice2Selected(_ sender: UIButton) {
        
        selected = 1
        
        dm.updateVote(roomID: roomID, questionIndex: questionIndex!, answerIndex: 1) {
            
            
        }
    }
    
    @IBAction func answerChoice3Selected(_ sender: UIButton) {
        
        selected = 2
        
        dm.updateVote(roomID: roomID, questionIndex: questionIndex!, answerIndex: 2) {
            
           
            
        }
    }
    
    @IBAction func answerChoice4Selected(_ sender: UIButton) {
        
        selected = 3
        
        dm.updateVote(roomID: roomID, questionIndex: questionIndex!, answerIndex: 3) {
            
           
            
        }
    }
    
    
    
    
    
    //state transition from pending to active, increase currentQuestion by 1
    @IBAction func nextQuestion(_ sender: UIButton) {
        
        
        let room = db.collection(K.FStore.collectionName).document(roomID)
        
        room.updateData(["state": "active"])
        
        
    }
    
    
    
//    func loadNextQuestion() {
//
//        db.collection(K.FStore.collectionName).document(roomID).collection("questions").addSnapshotListener { (querySnapshot, error) in
//
//            if let e = error {
//                print(error)
//            } else {
//
//                if let snapshotDocuments = querySnapshot?.documents {
//
//                    for doc in snapshotDocuments {
//
//                        let data = doc.data()
//
//                        if let currentQuestion = data["current"] as? Bool {
//
//                            if (currentQuestion == true) {
//
//                                if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int] {
//
//                                    self.question = MCQ(question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, current: true)
//
//                                }
//
//                                self.updateQuestion()
//
//                            }
//                        }
//
//
//                    }
//
//                }
//
//            }
//        }
//
//
//    }
    
    
    
    func updateQuestion() {
        
        questionLabel.text = question?.question
        
        if let answer1 = question?.answerChoices[0] {
            answerChoice1.setTitle(answer1, for: .normal)
        }

        if let answer2 = question?.answerChoices[1] {
            answerChoice2.setTitle(answer2, for: .normal)
        }
        
        if let answer3 = question?.answerChoices[2] {
            answerChoice3.setTitle(answer3, for: .normal)
        }
        
        if let answer4 = question?.answerChoices[3] {
            answerChoice4.setTitle(answer4, for: .normal)
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

}
