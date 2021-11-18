//
//  ViewController.swift
//  Leo
//
//  Created by Kai Stout on 7/9/21.
//

import UIKit
import Firebase

class WelcomeViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    let dm = DataManager()
    @IBOutlet weak var codeTextField: UITextField!
    
    
    @IBAction func unwindToWelcomeViewController(segue: UIStoryboardSegue) {
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("App opened")
        // Do any additional setup loading the view.
        if let id = DataManager.ID {
            print("Segue to room")
        }
    }

    
    @IBAction func joinPressed(_ sender: Any) {
        
        if let code = codeTextField.text {
            print(code)
            let docRef = db.collection(K.FStore.collectionName).document(code)
           
            docRef.getDocument { (doc, error) in
                
                if let e = error {
                    print(e)
                    return
                }
                
                if let room = doc, room.exists {
                    
                    DataManager.ID = code
                    
                    //selects proper vc based on state of room when joined
                    if let data = doc?.data(), let state = data["state"] as? String{
           
                        self.performSegue(withIdentifier: "welcomeToActiveRoom", sender: self)
                      
                        
                    }
                    
                } else {
                    
                    let alert = UIAlertController(title: "Join code invalid", message: "", preferredStyle: .alert)
                        
                    let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                        //user retries join code
                    }
                    
                    alert.addAction(action)
                    
                    self.present(alert, animated: true, completion: nil)
                
                }
                    
                
                
                
            }
        
            
            
        }
       
        
    }
    
   

}

