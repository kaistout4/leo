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
        print("Saving questions")
        print(leoViewControllers.count)
        var count = 0
        for vc in leoViewControllers {
            
            let vc = vc as! AddQuestionViewController
            
            vc.addQuestion { error, index in
                
                switch error {
                
                case "noQuestion":
                    print("Case: no question")
                    let alert = UIAlertController(title: "Question " + String(index!+1) + ": Missing Question", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                case "noAnswerSelected":
                    print("Case: no answer selected")
                    let alert = UIAlertController(title: "Question " + String(index!+1) + ": Missing Answer Selection", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                case "noAnswerChoice":
                    print("Case: no answers")
                    let alert = UIAlertController(title: "Question " + String(index!+1) + ": No Answer Choice", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                default:
                    count+=1
                    break
                }
            }
        }
        
        dm.updateQuestionCountOfRoom(roomID: roomID, to: count) {
            
            
        }
        
    }
    
    func loadFirstViewController() {
        
        let vc = self.generateAddQuestionViewController()
        vc.questionIndex = 0
        self.leoViewControllers.append(vc)
        
        if let firstQuestionViewController = leoViewControllers.first {
            setViewControllers([firstQuestionViewController], direction: .forward, animated: true, completion: nil)
        }
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
//            if questions.count == 0 {
//                if let firstQuestionViewController = leoViewControllers.first {
//                    setViewControllers([firstQuestionViewController], direction: .forward, animated: true, completion: nil)
//                }
//            } else {
//                if let lastQuestionViewController = leoViewControllers.last {
//                    setViewControllers([lastQuestionViewController], direction: .forward, animated: true, completion: nil)
//                }
//            }
//
//
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
            
            self.performSegue(withIdentifier: "roomManagerToActiveQuestions", sender: self)
            
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
            
        for i in 0...questions.count-1 {
                
            let vc = generateAddQuestionViewController()
            vc.question = questions[i]
            vc.questionIndex = i
            leoViewControllers.append(vc)
            
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
