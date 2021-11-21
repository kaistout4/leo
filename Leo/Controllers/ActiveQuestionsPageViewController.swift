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
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    let dm = DataManager()
    
    var leoViewControllers: [UIViewController] = []
    
    var user = DataManager.user
    
    let ID = DataManager.ID!
    
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
        
        self.title = "ID: " + ID
       
        if (user == "student") {
            exitButton.title = "Leave"
            navigationController?.isToolbarHidden = true
            
            //Loading screen needed
            loadFirstViewController()
        } else if (user == "teacher") {
            navigationController?.isToolbarHidden = false
            exitButton.title = "End Room"
            dm.updateState(roomID: ID, state: "active") {
                self.loadViewControllers()
            }
           
        }
      
    }
    
    
    //Three cases: show results, next question, session edned
    func listenForUpdatesAsStudent() {
        
        let db = Firestore.firestore()
        
        let room = db.collection(K.FStore.collectionName).document(ID)
        
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
                                let vc = self.leoViewControllers[currentQuestion] as! QuestionViewController
//                                self.dm.updateVote(roomID: self.ID, questionIndex: self.currentQuestion, answerIndex: vc.selected) {
//
//                                }
                                self.dm.reloadQuestion(from: self.ID, with: currentQuestion) { question in
                                    
                                    vc.hideResults = false
                                    vc.question = question
                                }
                            }
                            
                            if self.currentQuestion != currentQuestion {
                                self.currentQuestion = currentQuestion
                                self.addNextQuestionViewController()
                                
                            }
                        }
                            

                    }
                    
                    
                }
            }
            
            
            
        }
        
        
    }
    
    
    
    @IBAction func shareRoom(_ sender: Any) {
        let url = "uptake://join/\(ID)"
        UIPasteboard.general.string = url
        let alert = UIAlertController(title: "Link copied to clipboard", message: "", preferredStyle: .alert)
        self.present(alert, animated: true) {
            
        }
        alert.dismiss(animated: true) {
            
        }
        
    }
    
    
    @IBAction func updateQuestion(_ sender: UIBarButtonItem) {
        
        if questionState == "closed" {
            pagingDisabled = true
            setViewControllers([currentViewController], direction: .forward, animated: false)
            print(viewControllers?.count)
            print(pagingDisabled)
            questionState = "active"
            questionButton.tintColor = UIColor(named: "IncorrectColor")
            questionButton.title = "End Question"
            dm.updateCurrentQuestion(roomID: ID, index: currentQuestion) {
                
            }
            
        } else if questionState == "active" {
            pagingDisabled = false
            questionState = "closed"
            if let viewControllerIndex = leoViewControllers.firstIndex(of: currentViewController) {
                setViewControllers([leoViewControllers[viewControllerIndex]], direction: .forward, animated: false)
            }
            print(pagingDisabled)
            questionButton.tintColor = UIColor(named: "SecondaryLabelColor")
            questionButton.title = "Closed"
            questionButton.isEnabled = false
            closedQuestions.append(currentQuestion)
            dm.updateState(roomID: ID, state: "results") {
              
            }
            
        }
        
        
        
        
    }
    
    
    @IBAction func prevQuestion(_ sender: Any) {
        if !pagingDisabled {
            if let viewControllerIndex = leoViewControllers.firstIndex(of: currentViewController as! QuestionViewController) {
                if viewControllerIndex != 0 {
                    currentViewController = leoViewControllers[viewControllerIndex - 1] as! QuestionViewController
                    setViewControllers([leoViewControllers[viewControllerIndex - 1]], direction: .reverse, animated: true)
                }
            }
        }
    }
    
    @IBAction func nextQuestion(_ sender: Any) {
        if !pagingDisabled {
            if let viewControllerIndex = leoViewControllers.firstIndex(of: currentViewController as! QuestionViewController) {
                if viewControllerIndex != leoViewControllers.count - 1 {
                    currentViewController = leoViewControllers[viewControllerIndex + 1] as! QuestionViewController
                    setViewControllers([leoViewControllers[viewControllerIndex + 1]], direction: .forward, animated: true)
              
                }
            }
        }
    }
    

    

    func reloadQuestions() {
        
        dm.reloadQuestions(from: ID) { questions in
            //NEED TO ADD: error handling if there are no questions
       
            if questions != nil {
                self.questions = questions!
                
            }
        }
        
    }
    
    func loadViewControllers() {
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
        
        dm.reloadQuestions(from: ID) { questions in

            if questions != nil {
                self.questions = questions!
                
                for q in questions! {
                    print(q.question)
                }
                
                let vc = self.generateQuestionViewController()
                vc.question = questions![0]
                vc.questionIndex = 0
                self.leoViewControllers.append(vc)
                if let firstQuestionViewController = self.leoViewControllers.first as? QuestionViewController {
                    self.currentViewController = firstQuestionViewController as! QuestionViewController
                    self.setViewControllers([firstQuestionViewController], direction: .forward, animated: true, completion: nil)
                    
                }
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
            
            let alert = UIAlertController(title: "End Room", message: "Are you sure you want to end the session? Results will not save.", preferredStyle: .alert)
            let leave = UIAlertAction(title: "Leave", style: .destructive) { (action) in
                self.dm.updateState(roomID: self.ID, state: "closed") {
                    self.performSegue(withIdentifier: "unwindToMaster", sender: self)
                }
            }
            let stay = UIAlertAction(title: "Stay", style: .cancel) { (action) in
            }
            alert.addAction(leave)
            alert.addAction(stay)
            self.present(alert, animated: true)
            
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
//        print(viewControllers?.count)
//        print("Paging disabled: " + String(pagingDisabled))
        if pagingDisabled {
            //print("Not swipable")
            return nil
        }
        
        if let viewControllerIndex = leoViewControllers.firstIndex(of: viewController as! QuestionViewController) {
            print("View controller index: " + String(viewControllerIndex))
                if (viewControllerIndex == 0) {
                    
                    return nil
                    
                } else {
                    
                    return leoViewControllers[viewControllerIndex - 1]
                
                }
            
            }
        
        return nil
        
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        print(viewControllers?.count)
//        print("Paging disabled: " + String(pagingDisabled))
        if pagingDisabled {
            //print("Not swipable")
            return nil
        }
        
        if let viewControllerIndex = leoViewControllers.firstIndex(of: viewController as! QuestionViewController) {
            print("View controller index: " + String(viewControllerIndex))
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
                } else if questionState != "active" {
                        questionButton.title = "Start Question"
                        questionButton.isEnabled = true
                }
            }
        }
    }
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        print("willTransitionTo")
        
    }
    
}
