//
//  RoomPageViewController.swift
//  Leo
//
//  Created by Kai Stout on 9/5/21.
//

import UIKit
import Firebase

class EditQuestionsPageViewController: UIPageViewController {
  
    
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
     
    
    @IBAction func saveQuestions(_ sender: UIBarButtonItem) {
        
        for vc in leoViewControllers {
            
            let vc = vc as! AddQuestionViewController
            
            vc.addQuestion { error, index in
                
                if let error = error {
                    if error == true {
                        print("Error adding a question")
                    }
                   
                }
            }
        }
        
        dm.updateQuestionCountOfRoom(roomID: roomID, to: leoViewControllers.count) {
            
            
        }
        
    }
    
    func loadFirstViewController() {
        
        let vc = self.generateAddQuestionViewController()
        vc.questionIndex = 0
        self.leoViewControllers.append(vc)
        
    }
    
    
    @IBAction func newAddQuestionViewController(_ sender: UIBarButtonItem) {
        
        let newVC = generateAddQuestionViewController()
        newVC.questionIndex = leoViewControllers.count
        leoViewControllers.append(newVC)
        
        if let lastQuestionViewController = leoViewControllers.last {
            
            setViewControllers([lastQuestionViewController], direction: .forward, animated: true, completion: nil)
            
        }
    }
    
    
    let dm = DataManager()
    
    var leoViewControllers: [UIViewController] = []
        
//        didSet {
//
//            if let firstQuestionViewController = leoViewControllers.last {
//
//                setViewControllers([firstQuestionViewController], direction: .forward, animated: true, completion: nil)
//
//            }
//        }
        
    

    let user = User.user
    
    let roomID = User.roomID
    
    var questions: [MCQ] = []
    
    var currentQuestion = 0
    
    var currentViewController: QuestionViewController = QuestionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        print("test")
        print(roomID)
        
        self.title = "ID: " + roomID
        
        dm.reloadQuestionsFrom(roomID: roomID) { questions in
            
            if let questions = questions {
                
                if questions.count == 0 {
                    
                    self.loadFirstViewController()
                    
                } else {
                    
                    self.questions = questions
                    print("Load question VCs")
                    self.loadAddQuestionViewControllers()
                }
                
                
            }
            
            
        }
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func startRoom(_ sender: Any) {
        
        dm.updateState(roomID: roomID, state: "active") {
            
            self.performSegue(withIdentifier: "roomManagerToActiveRoom", sender: self)
            
        }
        
        
        
    }
    
    func reloadQuestions() {
        
        dm.reloadQuestionsFrom(roomID: roomID) { questions in
            //NEED TO ADD: error handling if there are no questions
       
            if questions != nil {
                self.questions = questions!
                
            }
        }
        
    }
    
//    func loadResultsCurrentViewController() {
//
//        print("loadResultsCurrentViewController")
//
//        dm.reloadQuestionsFrom(roomID: roomID) { questions in
//
//            self.currentViewController.question = self.questions[self.currentQuestion]
//
//            print("Calls show results")
//            self.currentViewController.showResults()
//
//        }
//
//    }
  
    
    func loadNewViewController() {
        
        dm.reloadQuestionsFrom(roomID: roomID) { questions in
            //NEED TO ADD: error handling if there are no questions
       
            if questions != nil {
                //print("Load new view controller question count: " + String(questions!.count))
                self.questions = questions!
                
                
                    
                }
                
            
                
        }
        
        
    }
    
    func generateAddQuestionViewController() -> AddQuestionViewController {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddQuestionViewController") as! AddQuestionViewController
        
        return vc
    }
    
    
    
    
    
    
    
    
    
    
    
    func loadAddQuestionViewControllers() {
        
       
        print(self.questions.count)
            
        for q in questions {
                
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddQuestionViewController") as? AddQuestionViewController {
                    
                vc.question = q
                
                leoViewControllers.append(vc)
            }
        }
        if let firstQuestionViewController = leoViewControllers.first {
            
            setViewControllers([firstQuestionViewController], direction: .forward, animated: true, completion: nil)
            
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


extension EditQuestionsPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        if let viewControllerIndex = leoViewControllers.firstIndex(of: viewController as! AddQuestionViewController) {
                
                if (viewControllerIndex == 0) {
                    
                    return nil
                    
                } else {
                    
                    return leoViewControllers[viewControllerIndex - 1]
                
                }
            
            }
        
        return nil
        
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let viewControllerIndex = leoViewControllers.firstIndex(of: viewController as! AddQuestionViewController) {
                
                if (viewControllerIndex == leoViewControllers.count - 1) {
                    
                    return nil
                    
                } else {
                    
                    return leoViewControllers[viewControllerIndex + 1]
                
                }
        }
            
        return nil

    
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return leoViewControllers.count
    }
    
}

extension EditQuestionsPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        
        if let currVc = self.viewControllers?.first as? QuestionViewController {
            
            currentViewController = currVc
        }
        
        
    }
    
    
}
