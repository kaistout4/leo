//
//  MasterViewController.swift
//  Leo
//
//  Created by Kai Stout on 7/10/21.
//

import UIKit
import Firebase

class MasterViewController: UIViewController {

    
    var rooms: [Room] = []
    @IBAction func unwindToMasterViewController(segue: UIStoryboardSegue) {
            
        loadRooms()
        
    }
    
    @IBOutlet weak var roomsTableView: UITableView!
    
    let db = Firestore.firestore()
    
    let dm = DataManager()
    
    
   // var  questions = [MCQ(question: "How old are you?", answerChoices: ["9", "10", "11", "12"], correctAnswer: 1, votes: [0, 0, 0, 0])]
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
    }
    
    
    
    @IBAction func createRoom(_ sender: UIBarButtonItem) {
        
        let roomID = createRoomID()
        
        var title = ""
        
        var newRoom: Room?
        User.roomID = roomID
        
        User.user = "teacher"
        
        let alert = UIAlertController(title: "Create room title", message: "", preferredStyle: .alert)
        
        
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        
        let action = UIAlertAction(title: "Ok", style: .default) { (action) in
            
            if let field = alert.textFields?[0] {
                
                print("Text field exists")
                if field.text == "" {
                    
                    print("Romm has no name")
                    title = "Unnamed"
                    
                    
                } else {
                    
                    title = field.text!
                    print("Room has name: " + title)
                 
                }
                
                newRoom = Room(id: roomID, title: title, questionCount: 0)
                
                self.rooms.append(newRoom!)
                
                if let email = Auth.auth().currentUser?.email {
                    
                    self.db.collection(K.FStore.collectionName).document(roomID).setData(["title" : newRoom!.title, "state" : "pending", "user" : email, "questionCount" : 0, "currentQuestion" : 0, "userCount" : 0])
                    
                    print("Room created")
                }
               
                
                self.performSegue(withIdentifier: "masterToRoomPage", sender: self)
                
            }
            
            
            
        }
        alert.addAction(action)
   
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func loadRooms() {
        
        print("Loading rooms")
        if let email = Auth.auth().currentUser?.email {
            
            dm.loadRooms(user: email) { rooms in
                
                if let userRooms = rooms {
                    
                    print("Rooms successfully loaded")
                    
                    self.rooms = userRooms
                    
                    self.roomsTableView.reloadData()
                } else {
                    
                    
                }
                
            }
            
        
        }
        
    }
    
    func createRoomID() -> String {
        
        return "AQ7Y82"
        
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.user = "teacher"
        roomsTableView.dataSource = self
        roomsTableView.delegate = self
        
        roomsTableView.register(UINib(nibName: "RoomCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        
      
        loadRooms()
        
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

extension MasterViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Adding cell to table view")
        let cell = roomsTableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! RoomCell
        
        
        cell.roomTitle.text = rooms[indexPath.row].title
        cell.questionCount.text =  String(rooms[indexPath.row].questionCount) + " questions"
        cell.roomID = rooms[indexPath.row].ID
        
        return cell
    }
    
    
    
    
    
}

extension MasterViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Row selected")
        User.roomID = rooms[indexPath.row].ID
        
        self.performSegue(withIdentifier: "masterToRoomPage", sender: self)
        
    }
    
    
    
    
    
}



