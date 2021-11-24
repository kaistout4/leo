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
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var joinButton: UIButton!
    @IBAction func unwindToWelcomeViewController(segue: UIStoryboardSegue) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        joinView.layer.cornerRadius = 10.0
        joinView.layer.shadowColor = UIColor.black.cgColor
        joinView.layer.shadowRadius = 9.0
        joinView.layer.shadowOpacity = 0.15
        loginView.layer.cornerRadius = 10.0
        loginView.layer.shadowColor = UIColor.black.cgColor
        loginView.layer.shadowRadius = 9.0
        loginView.layer.shadowOpacity = 0.15
        joinButton.isHidden = true
        codeTextField.delegate = self
        print("App opened")
        // Do any additional setup loading the view.
        
    }
    override func viewWillAppear(_ animated: Bool) {
        if let id = DataManager.ID {
            self.performSegue(withIdentifier: "welcomeToActiveRoom", sender: self)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom + 50, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
    }
    
    @IBAction func joinPressed(_ sender: Any) {
        
        if let code = codeTextField.text, codeTextField.text != "" {
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
                      
                } else {
                    
                    let alert = UIAlertController(title: "Join code invalid", message: "", preferredStyle: .alert)
                        
                    let action = UIAlertAction(title: "Try Again", style: .default) { (action) in
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
    
    @IBAction func register(_ sender: Any) {
        self.performSegue(withIdentifier: "welcomeToRegister", sender: self)
    }
    
    
   

}

extension WelcomeViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        joinButton.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            joinButton.isHidden = true
        }
    }
}

extension UIImage {
    
    class func image(with color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(rect)
            let image = UIImage(cgImage: context.makeImage()!)
            return image
        }
        UIGraphicsEndImageContext()
        return UIImage()
    }
}
