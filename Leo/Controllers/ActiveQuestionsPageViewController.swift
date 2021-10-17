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
    
    let roomID = User.roomID
    
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
            
            
            
        } else if (user == "teacher") {
            
            exitButton.title = "End room"
           
        }
        
        
        loadFirstViewController()
    

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
                                
                                self.exitRoom()
                                
                            }
                            
                            if (state == "results") {
                                
                                
                                
                                print("results")
                                let vc = self.leoViewControllers[currentQuestion] as! QuestionViewController
                                
                                self.dm.reloadQuestionFrom(roomID: self.roomID, withIndex: currentQuestion) { question in
                                    
                                    print(question?.question)
                                    vc.question = question
                                    vc.refreshResults()
                                }
                                
                                
                            }
                            
                            if self.currentQuestion != currentQuestion {
                                
                                self.currentQuestion = currentQuestion
                                self.addNextQuestionViewController()
                                
                            }
                            
//                            if (currentQuestion != self.currentQuestion) {
//
//                                print("Next question")
//                            }
                            
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
        
        dm.nextQuestion(roomID: roomID) {
            
            self.currentQuestion += 1
            self.addNextQuestionViewController()
            
        }
        
        
    }
    
    
    
    
    func exitRoom() {
        
        let alert = UIAlertController(title: "Session ended", message: "", preferredStyle: .alert)
            
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            self.performSegue(withIdentifier: "unwindToWelcomeView", sender: self)
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    func reloadQuestions() {
        
        dm.reloadQuestionsFrom(roomID: roomID) { questions in
            //NEED TO ADD: error handling if there are no questions
       
            if questions != nil {
                self.questions = questions!
                
            }
        }
        
    }
    
    
    func loadFirstViewController() {
        
        dm.reloadQuestionsFrom(roomID: roomID) { questions in
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
                
//                self.listenForUpdatesAsStudent()
                
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
