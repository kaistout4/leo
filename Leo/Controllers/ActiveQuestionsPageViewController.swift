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
    
    let dm = DataManager()
    
    var leoViewControllers: [UIViewController] = [] {
        
        didSet {
            
            if let firstQuestionViewController = leoViewControllers.last {
                
                setViewControllers([firstQuestionViewController], direction: .forward, animated: true, completion: nil)
                
            }
        }
        
    }

    let user = User.user
    
    var roomID = User.roomID
    
    var questions: [MCQ] = []
    
    var currentQuestion = 0
    
    var currentViewController: QuestionViewController = QuestionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        print("ActiveQuestionsVC loaded")
        
        self.title = "ID: " + roomID
        
        
        if (user == "student") {
            exitButton.title = "Leave"
            navigationController?.isToolbarHidden = true
        } else if (user == "teacher") {
            navigationController?.isToolbarHidden = false
            exitButton.title = "End Room"
           
        }
        
        print(roomID)
        
        //Loading screen needed
        dm.updateState(roomID: roomID, state: "active") {
            self.loadFirstViewController()
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
    
    
    @IBAction func showResults(_ sender: UIBarButtonItem) {
        
        dm.updateState(roomID: roomID, state: "results") {
        
            
        }
        
    }
    
    
    
    @IBAction func nextQuestion(_ sender: UIBarButtonItem) {
        
        if currentQuestion != questions.count - 1 {
            dm.nextQuestion(roomID: roomID) {
                
                self.currentQuestion += 1
                self.addNextQuestionViewController()
                
            }
        }
       
        
    }
    

    func reloadQuestions() {
        
        dm.reloadQuestions(from: roomID) { questions in
            //NEED TO ADD: error handling if there are no questions
       
            if questions != nil {
                self.questions = questions!
                
            }
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
    
    func generateQuestionViewControllers() -> [QuestionViewController] {
        
        var vcs: [QuestionViewController] = []
        

                print(self.questions.count)
            
            for q in questions {
                
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionViewController") as? QuestionViewController {
                    
                    vc.question = q
                    vcs.append(vc)
                
                }
               
        }
        
        return vcs
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
        
        return nil
        
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
        return nil

    
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return leoViewControllers.count
    }
    
}

extension ActiveQuestionsPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
        if let currVc = self.viewControllers?.first as? QuestionViewController {
            
            currentViewController = currVc
        }
        
        
    }
    
    
}
