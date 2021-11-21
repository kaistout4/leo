//
//  RegisterViewController.swift
//  Leo
//
//  Created by Kai Stout on 7/10/21.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text, let confirmPassword = confirmPasswordTextField.text {
            
            if password == confirmPassword {
                print(password.count)
                if password.count < 6 {
                    let alert = UIAlertController(title: "Error", message: "The password must be 6 characters or longer.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .destructive) { (action) in
                        
                    }
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                   
                } else {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        
                        if let e = error {
                            let alert = UIAlertController(title: "Error", message: "The email address is already in use by another count.", preferredStyle: .alert)
                            let action = UIAlertAction(title: "Ok", style: .destructive) { (action) in
                                
                            }
                            alert.addAction(action)
                            self.present(alert, animated: true, completion: nil)
                            print(e)
                        } else {
                            DataManager.user = "teacher"
                            self.performSegue(withIdentifier: "registerToMaster", sender: self)
                        }
                        
                    }
                }
            } else {
                let alert = UIAlertController(title: "Passwords do not match", message: "", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .default) { (action) in
                    
                }
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
      
        
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
