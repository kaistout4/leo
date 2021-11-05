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
            
            if vc.isViewLoaded {
                vc.saveData()
            }
            
            vc.addQuestion { error, index in
                
                switch error {
                
                case "noQuestion":
                    print("Case: no question")
                    let alert = UIAlertController(title: "Missing Question", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                case "noAnswerSelected":
                    print("Case: no answer selected")
                    let alert = UIAlertController(title: "Missing Answer Selection", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                case "noAnswerChoice":
                    print("Case: no answers")
                    let alert = UIAlertController(title: "Missing Answer Choice", message: "", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                default:
                    print("here")
                    count+=1
                    self.questions.append(vc.question!)
                    break
                }
            }
        }
        print(roomID)
        print(count)
        dm.updateQuestionCount(roomID: roomID, to: count) {
            
            
        }
        
    }
    
    func loadFirstViewController() {
        
        let vc = self.generateAddQuestionViewController()
        vc.questionIndex = 0
        
        leoViewControllers.append(vc)
        currentViewController = vc
        
        if let firstQuestionViewController = leoViewControllers.first {
            setViewControllers([firstQuestionViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func newAddQuestionViewController(_ sender: UIBarButtonItem) {
        
        let newVC = generateAddQuestionViewController()
        newVC.questionIndex = leoViewControllers.count
        
        leoViewControllers.append(newVC)
        currentViewController = newVC
        
        if let lastQuestionViewController = leoViewControllers.last {
            setViewControllers([lastQuestionViewController], direction: .forward, animated: true, completion: nil)
            
        }
    }
    
    
    let dm = DataManager()
    
    var leoViewControllers: [UIViewController] = []
    
    let user = User.user
    
    let roomID = User.roomID
    
    var questions: [MCQ] = []
    
    var currentQuestion = 0
    
    var currentViewController: AddQuestionViewController = AddQuestionViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self

        print(roomID)
        
        self.title = "ID: " + roomID
        
        dm.reloadQuestions(from: roomID) { questions in
            
            if let questions = questions {
                
                if questions.count == 0 {
                    print("Count is 0")
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
    
    
    //NEED TO ADD: If index is first, then delete the first and show next
    @IBAction func deleteQuestion(_ sender: Any) {
        
        if leoViewControllers.count == 0 {
            return
        }
        
        if let index = leoViewControllers.firstIndex(of: currentViewController) {
            print("Deleting vc at index " + String(index))
            if index == 0 {
                setViewControllers([leoViewControllers[index+1]], direction: .forward, animated: true, completion: nil)
            } else {
                setViewControllers([leoViewControllers[index-1]], direction: .forward, animated: true, completion: nil)
            }
        
            leoViewControllers.remove(at: index)
            updateQuestionIndexes()
            dm.deleteQuestion(from: roomID, with: index)
        }
        
    }
    
    func updateQuestionIndexes() {
        for i in 0...leoViewControllers.count-1 {
            let vc = leoViewControllers[i] as! AddQuestionViewController
            vc.questionIndex = i
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
        if let firstAddQuestionViewController = leoViewControllers.first as? AddQuestionViewController {
            currentViewController = firstAddQuestionViewController as! AddQuestionViewController
            setViewControllers([firstAddQuestionViewController], direction: .forward, animated: true, completion: nil)
            
        }
               
    }
    
    @IBAction func exitEditor(_ sender: UIBarButtonItem) {
        
        var currQuestions: [MCQ] = []
        
        if questions.count != leoViewControllers.count {
            print("Save warning")
        }
        
        for vc in leoViewControllers {
            
            let vc = vc as! AddQuestionViewController
            currQuestions.append(vc.getQuestion())
            
        }
        
        performSegue(withIdentifier: "unwindToMaster", sender: self)
        
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
        if completed {
            if let currVc = self.viewControllers?.first as? AddQuestionViewController {
                currentViewController = currVc
                print(currentViewController.questionIndex)
            }
        }
    }
    
    //Before transition to new question, save UI text to local AddQuestionViewController variables
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        currentViewController.saveData()
        
    }
    
}
