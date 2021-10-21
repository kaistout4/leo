//
//  DataManager.swift
//  Leo
//
//  Created by Kai Stout on 9/5/21.
//

import Foundation
import Firebase

class DataManager {
    
    var questions: [MCQ]? = []
    
    
    let db = Firestore.firestore()
    static var shared = { return DataManager() }()
    
    init() {
        // load questions sample
//        loadQuestionsFrom(roomID: "1") { questions in
//
//            if (questions == nil) {
//
//                //error fetching questions from database
//            }
//
//
//            self.questions = questions
//        }
        
    }
    
    func loadRooms(user: String, completion: @escaping (_ rooms: [Room]?) -> Void) {
        
        var rooms: [Room] = []
        
        db.collection(K.FStore.collectionName).whereField("user", isEqualTo: user).getDocuments { querySnapshot, error in
            
            if let error = error {
                
                print(error)
                
            } else {
                
                if let snapshotDocuments = querySnapshot?.documents {
                    
                    print(snapshotDocuments.count)
                    
                    for doc in snapshotDocuments {
                         
                        let data = doc.data()
                        
                        print(data["questionCount"] as! Int)
                        
                        rooms.append(Room(id: doc.documentID, title: data["title"] as! String, questionCount : data["questionCount"] as! Int))
                            
                        
                    }
                    
                    completion(rooms)
                }
                
                completion(nil)
                
            }
            
        }
        
    }
    
    func updateState(roomID: String, state: String, completion: @escaping () -> Void) {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["state" : state])
        
        completion()
        
    }
    
    func nextQuestion(roomID: String, completion: @escaping () -> Void) {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["state" : "active"])
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["currentQuestion" : FieldValue.increment(Int64(1))])
        
        completion()
        
    }
    
    func userCount(roomID: String, completion: @escaping (_ count: Int) -> Void) {
        
        db.collection(K.FStore.collectionName).document(roomID).getDocument { documentSnapshot, error in
            
            if let doc = documentSnapshot {
                
                if let data = doc.data() {
                    
                    let count = data["userCount"] as! Int
                    
                    completion(count)
                }
                
            }
        }
        
    }
    
    
    
    func updateVote(roomID: String, questionIndex: Int, answerIndex: Int, completion: @escaping () -> Void) {
    
        var vote = "resultsA"
        switch answerIndex {
            
            case 1:
                vote = "resultsB"
            case 2:
                vote = "resultsD"
            case 3:
                vote = "resultsD"
            default:
                break
            
        }
        
        db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(String(questionIndex)).updateData([vote : FieldValue.increment(Int64(1))])
        
        
        
    }
    
    func updateQuestionCountOfRoom(roomID: String, to: Int, completion: @escaping () -> Void) {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["questionCount" : to])
    }
    
    
    func addQuestionToRoom(roomID: String, question: String, answerChoices: [String], correctAnswers: [Int], index: Int, time: Double, completion: @escaping () -> Void) {
        
        print("Added question to room")
        if let email = Auth.auth().currentUser?.email {
        
            db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(String(index)).setData(["question": question, "answerChoices": answerChoices, "correctAnswers": correctAnswers, "resultsA" : 0, "resultsB" : 0, "resultsC" : 0, "resultsD" : 0, "time": Date().timeIntervalSince1970])
        
        
        }
    }
    
    func reloadQuestionFrom(roomID: String, withIndex: Int, completion: @escaping (_ question: MCQ?) -> Void) {
        
        db.collection("rooms").document(roomID).collection("questions").document(String(withIndex)).getDocument { doc, error in
            
            if let doc = doc {
                
                if let data = doc.data() {
                   
                    if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int {
                        
                        completion(MCQ(question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD]))
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    func reloadQuestionsFrom(roomID: String, completion: @escaping (_ questions: [MCQ]?) -> Void) {
        
        db.collection("rooms").document(roomID).collection("questions").getDocuments { (querySnapshot, error) in
            
            if let e = error {
                
                completion(nil)
                print(e)
            } else {
                
                if let snapshotDocuments = querySnapshot?.documents {
                    
                    var questions: [MCQ] = []
                    
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int {
                            
                            questions.append(MCQ(question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD]))
                            
                            print("MCQ appended")
                        }
                            
                    }
                    
                    completion(questions)
                    
                }
                
            }
        }
        
    }
    
    
}
