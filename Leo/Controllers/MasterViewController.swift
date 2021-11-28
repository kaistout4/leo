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
        print("Recieving unwind segue")
        if let vc = segue.source as? ActiveQuestionsPageViewController {
            if let ID = DataManager.ID {
                dm.updateState(roomID: ID, state: "closed") {
                }
                dm.clearResults(roomID: ID)
            }
        }
        loadRooms()
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let db = Firestore.firestore()
    
    let dm = DataManager()
    
    var selectedRoomIndex: Int = 0
    
   // var  questions = [MCQ(question: "How old are you?", answerChoices: ["9", "10", "11", "12"], correctAnswer: 1, votes: [0, 0, 0, 0])]
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        
        DataManager.ID = nil
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
        DataManager.ID = roomID
        
        let alert = UIAlertController(title: "Enter room title", message: "", preferredStyle: .alert)
        
        
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        let create = UIAlertAction(title: "Create", style: .default) { [weak self] action in
            guard let self = self else { return }
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
                    
                    self.db.collection(K.FStore.collectionName).document(roomID).setData(["title" : newRoom!.title, "state" : "closed", "user" : email, "questionCount" : 0, "currentQuestion" : 0, "userCount" : 0])
                }
                self.performSegue(withIdentifier: "masterToRoomPage", sender: self)
            }
        }
        alert.addAction(cancel)
        alert.addAction(create)
   
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func logoutUser(_ sender: Any) {
        DataManager.ID = nil
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        self.performSegue(withIdentifier: "unwindToWelcome", sender: self)
        
    }
    
    
    
    func loadRooms() {
    
        if let email = Auth.auth().currentUser?.email {
            
            dm.loadRooms(user: email) { [weak self] rooms in
                guard let self = self else { return }
                if let userRooms = rooms {
                    self.rooms = userRooms
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func createRoomID() -> String {
        let chars = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        var ID = ""
        for i in 0...5 {
            let index = Int.random(in: 0...35)
            print(chars[index])
            ID.append(chars[index])
        }
        return ID
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let nav = segue.destination as? UINavigationController, let controller = nav.topViewController as? ActiveQuestionsPageViewController {
            controller.questions = rooms[selectedRoomIndex].questions!
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //Loading screen needed
        loadRooms()
        // Do any additional setup after loading the view.
        self.title = "Your rooms"
        
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
        let edit = UIAction(title: "Edit room", image: UIImage(systemName: "pencil")) { [weak self] (action) in
            print("Edit mode")
            DataManager.ID = cell.roomID
            self?.performSegue(withIdentifier: "masterToRoomPage", sender: self)
            
        }
        let delete = UIAction(title: "Delete room", image: UIImage(systemName: "trash")) { [weak self] (action) in
            self?.dm.deleteRoom(roomID: cell.roomID, questionCount: (self?.rooms[index].questionCount)!)
            self?.rooms.remove(at: index)
            self?.tableView.reloadData()
            print("Delete room")
           
        }
        let rename = UIAction(title: "Rename", image: UIImage(systemName: "square.and.pencil")) { [weak self] (action) in
            
            let alert = UIAlertController(title: "Rename room", message: "Enter new title", preferredStyle: .alert)
            
            
            alert.addTextField { (textField) in
                textField.placeholder = "New title"
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
            
            let rename = UIAlertAction(title: "Rename", style: .default) { (action) in
                
                if let field = alert.textFields?[0] {
                    self?.rooms[index].title = field.text ?? ""
                    self?.tableView.reloadData()
                    self?.dm.rename(roomID: cell.roomID, newName: field.text ?? "")
                }
            }
            
            alert.addAction(cancel)
            alert.addAction(rename)
            self?.present(alert, animated: true, completion: nil)
        }
        let menu = UIMenu(title: "Menu", options: .displayInline, children: [edit, rename, delete])
        cell.editButton.menu = menu
        cell.editButton.showsMenuAsPrimaryAction = true
        
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
        cell.startButton.addTarget(self, action: #selector(startButtonAction(sender:)), for: .touchUpInside)
        configureCell(cell: cell, at: indexPath)
        cell.delegate = self
        return cell
    }
    
    @objc func startButtonAction(sender: UIButton) {
        
        selectedRoomIndex = sender.tag
        
        if rooms[sender.tag].questionCount == 0 {
            
            let alert = UIAlertController(title: "No Questions", message: "Add questions to start room", preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Ok", style: .destructive) { (action) in
                return
            }
            
            alert.addAction(action)
    
            self.present(alert, animated: true, completion: nil)
        } else {
            let ID = rooms[sender.tag].ID
            
            DataManager.ID = ID
            
            self.performSegue(withIdentifier: "masterToActiveQuestions", sender: self)
        }
    }
}

extension MasterViewController: UITableViewDelegate {
  
}

extension MasterViewController: RoomCellDelegate {
    func editButtonPressed(_ cell: RoomCell) {
        let index = cell.editButton.tag
        let edit = UIAction(title: "Edit room", image: UIImage(systemName: "pencil")) { [weak self] (action) in
            print("Edit mode")
            let id = self?.rooms[index].ID
            self?.performSegue(withIdentifier: "masterToActiveQuestions", sender: self)
            
        }
        let delete = UIAction(title: "Delete room", image: UIImage(systemName: "trash")) { [weak self] (action) in
            print("Delete room")
           
        }
        let menu = UIMenu(title: "Menu", options: .displayInline, children: [edit, delete])
        cell.editButton.menu = menu
        cell.editButton.showsMenuAsPrimaryAction = true
    }
}

protocol RoomCellDelegate: AnyObject {
    func editButtonPressed(_ cell: RoomCell)
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
    
    weak var delegate: RoomCellDelegate?
    
    var roomID = ""
    
    override func awakeFromNib() {
        clipsToBounds = false
        contentView.clipsToBounds = false
        roomBackground.layer.cornerRadius = 10.0
        roomBackground.layer.shadowColor = UIColor.black.cgColor
        roomBackground.layer.shadowRadius = 9.0
        roomBackground.layer.shadowOpacity = 0.15
        startButtonBackground.layer.cornerRadius = startButtonBackground.bounds.height / 2.0

    }
    
    @IBAction func edit(_ sender: Any) {
        delegate?.editButtonPressed(self)
    }
    
    
    
}

