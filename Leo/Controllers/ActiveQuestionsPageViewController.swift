//
//  RoomPageViewController.swift
//  Leo
//
//  Created by Kai Stout on 9/5/21.
//

import UIKit
import Firebase

class ActiveQuestionsPageViewController: UIPageViewController {
      
    @IBOutlet weak var exitButton: UIBarButtonItem!
    @IBOutlet weak var questionButton: UIBarButtonItem!
    
    let dm = DataManager()
    
    var leoViewControllers: [UIViewController] = []
    
    let user = User.user
    
    var roomID = User.roomID
    
    var questions: [MCQ] = []
    
    var currentQuestion = 0
    
    var questionState = "closed"
    
    var closedQuestions: [Int] = []
    
    var pagingDisabled = false
    
    var currentViewController: QuestionViewController = QuestionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        self.title = "ID: " + roomID
        
        if (user == "student") {
            exitButton.title = "Leave"
            navigationController?.isToolbarHidden = true
            
            //Loading screen needed
            loadFirstViewController()
        } else if (user == "teacher") {
            navigationController?.isToolbarHidden = false
            exitButton.title = "End Room"
            dm.updateState(roomID: roomID, state: "active") {
                self.loadViewControllers()
            }
           
        }
      
    }
    
    
    
    func listenForUpdatesAsStudent() {
        
        let db = Firestore.firestore()
        
        let room = db.collection(K.FStore.collectionName).document(roomID)
        
        
        
        room.addSnapshotListener { (doc, error) in
            
            if let e = error {
                
                print(e)
            } else {
                
                if let doc = doc {
                    
                    if let data = doc.data() {
                        
                        if let state = data["state"] as? String,
                           let currentQuestion = data["currentQuestion"] as? Int {
                            
                            
                            if (state == "closed") {
                                
                                self.sessionEnded()
                                
                            }
                            
                            if (state == "results") {
                                
                                print("Student: state results")
                                
                                let vc = self.leoViewControllers[currentQuestion] as! QuestionViewController
                                self.dm.updateVote(roomID: self.roomID, questionIndex: self.currentQuestion, answerIndex: vc.selected) {
                                    
                                }
                                
                                self.dm.reloadQuestion(from: self.roomID, with: currentQuestion) { question in
                                    
                                    vc.hideResults = false
                                    vc.question = question
                                }
                                
                                
                                
                            }
                            
                            if self.currentQuestion != currentQuestion {
                                
                                print("Student: next question")
                                self.currentQuestion = currentQuestion
                                self.addNextQuestionViewController()
                                
                            }
                        }
                            

                    }
                    
                    
                }
            }
            
            
            
        }
        
        
    }
    
    
    @IBAction func updateQuestion(_ sender: UIBarButtonItem) {
        
        if questionState == "closed" {
            pagingDisabled = true
            print(pagingDisabled)
            questionState = "active"
            questionButton.tintColor = UIColor(named: "IncorrectColor")
            questionButton.title = "End Question"
            dm.updateCurrentQuestion(roomID: roomID, index: currentQuestion) {
                
            }
            
        } else if questionState == "active" {
            pagingDisabled = false
            questionState = "closed"
            questionButton.tintColor = UIColor(named: "SecondaryLabelColor")
            questionButton.title = "Closed"
            questionButton.isEnabled = false
            closedQuestions.append(currentQuestion)
            dm.updateState(roomID: roomID, state: "results") {
              
            }
            
        }
        
        
        
        
    }
    
    
    @IBAction func prevQuestiom(_ sender: Any) {
    }
    
    @IBAction func nextQuestion(_ sender: Any) {
    }
    

    

    func reloadQuestions() {
        
        dm.reloadQuestions(from: roomID) { questions in
            //NEED TO ADD: error handling if there are no questions
       
            if questions != nil {
                self.questions = questions!
                
            }
        }
        
    }
    
    func loadViewControllers() {
        print(questions.count)
        print(questions)
        for i in 0...questions.count-1 {
                
            let vc = generateQuestionViewController()
            vc.question = questions[i]
            vc.questionIndex = i
            leoViewControllers.append(vc)
        }
        if let firstQuestionViewController = leoViewControllers.first as? QuestionViewController {
            currentViewController = firstQuestionViewController as! QuestionViewController
            setViewControllers([firstQuestionViewController], direction: .forward, animated: true, completion: nil)
            
        }
    }
    
    func loadFirstViewController() {
        
        dm.reloadQuestions(from: roomID) { questions in
            //NEED TO ADD: error handling if there are no questions
       
            if questions != nil {
                self.questions = questions!
                
                for q in questions! {
                    print(q.question)
                }
                
                let vc = self.generateQuestionViewController()
                vc.question = questions![0]
                vc.questionIndex = 0
                self.leoViewControllers.append(vc)
                
                self.listenForUpdatesAsStudent()
                
            }
                
        }
        
        
    }
    
    func addNextQuestionViewController() {
        
        let vc = generateQuestionViewController()
        
        vc.question = questions[currentQuestion]
        vc.questionIndex = currentQuestion
        self.leoViewControllers.append(vc)
        
        
    }
    
    
    func generateQuestionViewController() -> QuestionViewController {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
            
        return vc
        
        
    }
    
    @IBAction func leaveRoom(_ sender: UIBarButtonItem) {
        
        //if teacher, close room
        if user == "teacher" {
        
            dm.updateState(roomID: roomID, state: "closed") {
                self.performSegue(withIdentifier: "unwindToMaster", sender: self)
                
            
            }
        } else {
            performSegue(withIdentifier: "unwindToWelcome", sender: self)
        }
        
    }
    
    func sessionEnded() {
        
        let alert = UIAlertController(title: "Session ended", message: "", preferredStyle: .alert)
            
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            self.performSegue(withIdentifier: "unwindToWelcome", sender: self)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
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


extension ActiveQuestionsPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if pagingDisabled {
            print("Not swipable")
            return nil
        }
        
        if let viewControllerIndex = leoViewControllers.firstIndex(of: viewController as! QuestionViewController) {
                print(viewControllerIndex)
                if (viewControllerIndex == 0) {
                    
                    return nil
                    
                } else {
                    
                    return leoViewControllers[viewControllerIndex - 1]
                
                }
            
            }
        
        return nil
        
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if pagingDisabled {
            print("Not swipable")
            return nil
        }
        
        if let viewControllerIndex = leoViewControllers.firstIndex(of: viewController as! QuestionViewController) {
            print(viewControllerIndex)
                if (viewControllerIndex == leoViewControllers.count - 1) {
                    
                    return nil
                    
                } else {
                    
                    return leoViewControllers[viewControllerIndex + 1]
                
                }
        }
            
        return nil
    
    }
    
}

extension ActiveQuestionsPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currVc = self.viewControllers?.first as? QuestionViewController {
                currentViewController = currVc
                currentQuestion = currentViewController.questionIndex!
                if closedQuestions.contains(currentQuestion) {
                    questionButton.tintColor = UIColor(named: "SecondaryLabelColor")
                    questionButton.title = "Closed"
                    questionButton.isEnabled = false
                } else {
                    questionButton.tintColor = UIColor(named: "CorrectColor")
                    questionButton.title = "Start Question"
                    questionButton.isEnabled = true
                }
                //print(currentViewController.questionIndex)
            }
        }
    }
    
    
}
