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
    
    
    
    @IBOutlet weak var tableView: UITableView!
    
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
    
    @IBAction func logoutUser(_ sender: Any) {
        
         
        
        
    }
    
    
    
    func loadRooms() {
    
        if let email = Auth.auth().currentUser?.email {
            
            dm.loadRooms(user: email) { rooms in
                if let userRooms = rooms {
                    self.rooms = userRooms
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func createRoomID() -> String {
        
        return "AQ7Y89"
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let controller = nav.topViewController as? ActiveQuestionsPageViewController {
            controller.roomID = User.roomID
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        User.user = "teacher"
        tableView.dataSource = self
        tableView.delegate = self
        
        //Loading screen needed
        loadRooms()
        
        // Do any additional setup after loading the view.
    }
    
    func configureCell(cell: RoomCell, at indexPath: IndexPath) {
        
        let index = indexPath.row
        
        cell.roomID = rooms[index].ID
        cell.roomCode.text = rooms[index].ID
        cell.roomTitle.text = rooms[index].title
        switch rooms[index].questionCount {
            
        case 0:
            cell.question1Prefix.text = ""
            cell.question2Prefix.text = ""
            cell.question1Label.text = ""
            cell.question2Label.text = ""
            cell.moreQuestionsLabel.text = ""
        case 1:
            cell.question1Prefix.text = "1"
            cell.question1Label.text = rooms[index].questions![0].question
            cell.question2Prefix.text = ""
            cell.question2Label.text = ""
            cell.moreQuestionsLabel.text = ""
        case 2:
            cell.question1Prefix.text = "1"
            cell.question1Label.text = rooms[index].questions![0].question
            cell.question2Prefix.text = "2"
            cell.question2Label.text = rooms[index].questions![1].question
            cell.moreQuestionsLabel.text = ""
            
        default:
            
            cell.question1Prefix.text = "1"
            cell.question1Label.text = rooms[index].questions![0].question
            cell.question2Prefix.text = "2"
            cell.question2Label.text = rooms[index].questions![1].question
            cell.moreQuestionsLabel.text = "+ " + String(rooms[index].questionCount-2) + " more"
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

extension MasterViewController: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Adding cell to table view")
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! RoomCell
        cell.editButton.tag = indexPath.row
        cell.startButton.tag = indexPath.row
        cell.editButton.addTarget(self, action: #selector(editButtonAction(sender:)), for: .touchUpInside)
        cell.startButton.addTarget(self, action: #selector(startButtonAction(sender:)), for: .touchUpInside)
        
        configureCell(cell: cell, at: indexPath)
        return cell
    }
    
    @objc func startButtonAction(sender: UIButton) {
        
        let ID = rooms[sender.tag].ID
        User.roomID = ID
    
        self.performSegue(withIdentifier: "masterToActiveQuestions", sender: self)

    }
    
    @objc func editButtonAction(sender: UIButton) {
        
        let ID = rooms[sender.tag].ID
        User.roomID = ID
        
        self.performSegue(withIdentifier: "masterToRoomPage", sender: self)
    
    }
    
}

extension MasterViewController: UITableViewDelegate {
  
}

class RoomCell: UITableViewCell {
    
    @IBOutlet weak var roomBackground: UIView!
    @IBOutlet weak var roomCode: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var roomTitle: UILabel!
    @IBOutlet weak var question1Prefix: UILabel!
    @IBOutlet weak var question1Label: UILabel!
    @IBOutlet weak var question2Prefix: UILabel!
    @IBOutlet weak var question2Label: UILabel!
    @IBOutlet weak var moreQuestionsLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var startButtonBackground: UIView!
    
    
    var roomID = ""
    
    override func awakeFromNib() {
        roomBackground.layer.cornerRadius = 10.0
        startButtonBackground.layer.cornerRadius = startButtonBackground.bounds.height / 2.0
    }
    
}

