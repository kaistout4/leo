//
//  WaitingRoomViewController.swift
//  Leo
//
//  Created by Kai Stout on 8/20/21.
//

import UIKit
import Firebase

class WaitingRoomViewController: UIViewController {
    
    let db = Firestore.firestore()
    let code = User.roomID
    
    
    // handles waiting room based on state
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let docRef = db.collection(K.FStore.collectionName).document(code).addSnapshotListener { (documentSnapshot, error) in
            
            if let doc = documentSnapshot {
                
                let data = doc.data()
                
                if let state = data!["state"] as? String {
                        
                        
                    }
                }
            }
        }
        
        

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


