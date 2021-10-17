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
    
    @IBOutlet weak var codeTextField: UITextField!
    
    
    @IBAction func unwindToWelcomeViewController(segue: UIStoryboardSegue) {
        
        
        
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
                    
                    User.roomID = code
                    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup loading the view.
    }


}

