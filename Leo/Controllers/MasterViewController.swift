//
//  MasterViewController.swift
//  Leo
//
//  Created by Kai Stout on 7/10/21.
//

import UIKit
import Firebase

class MasterViewController: UIViewController {
    
    @IBOutlet weak var pastRoomsTableView: UITableView!
    
    let db = Firestore.firestore()
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
    }
    
    @IBAction func createRoom(_ sender: UIButton) {
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
