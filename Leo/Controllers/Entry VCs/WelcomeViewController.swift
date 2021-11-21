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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var joinView: UIStackView!
    @IBOutlet weak var loginView: UIStackView!
    
    @IBAction func unwindToWelcomeViewController(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        joinView.layer.cornerRadius = 10.0
        joinView.layer.shadowColor = UIColor.black.cgColor
        joinView.layer.shadowRadius = 9.0
        joinView.layer.shadowOpacity = 0.15
        loginView.layer.cornerRadius = 10.0
        loginView.layer.shadowColor = UIColor.black.cgColor
        loginView.layer.shadowRadius = 9.0
        loginView.layer.shadowOpacity = 0.15
        print("App opened")
        // Do any additional setup loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
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
                    DataManager.user = "student"
                    self.performSegue(withIdentifier: "welcomeToActiveRoom", sender: self)
                    //update user count
                      
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
    
    @IBAction func loginPressed(_ sender: Any) {
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) {  authResult, error in
                
                if let e = error {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .destructive) { (action) in
                        print(e.localizedDescription)
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                   
                    
                } else {
                    DataManager.user = "teacher"
                    
                    self.performSegue(withIdentifier: "welcomeToMaster", sender: self)
                }
            }
        }
    }
    
   

}


