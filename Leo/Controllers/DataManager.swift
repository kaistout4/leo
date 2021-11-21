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
    
    static var ID: String?
    static var user: String = "student"
    
    let db = Firestore.firestore()
    static var shared = { return DataManager() }()
    
    init() {

    }
    
    func loadRooms(user: String, completion: @escaping (_ rooms: [Room]?) -> Void) {
                
        db.collection(K.FStore.collectionName).whereField("user", isEqualTo: user).getDocuments { querySnapshot, error in
            
            if let error = error {
                
                print(error)
                completion(nil)
                
            } else {
                
                if let snapshotDocuments = querySnapshot?.documents {
                    
                    DispatchQueue.global().async {
                        
                        print(snapshotDocuments.count)
                        
                        let group = DispatchGroup()
                        var rooms: [Room] = []
                        
                        
                        for doc in snapshotDocuments {
                            
                            group.enter()
                            
                            let data = doc.data()
                            
                            print(data["questionCount"] as! Int)
                            
                            // Fetch the questions for each document
                            
                            self.db.collection("rooms").document(doc.documentID).collection("questions").getDocuments { querySnapshot, error in
                                
                                if let e = error {
                                    print(e)
                                    
                                } else {
                                    
                                    var questions: [MCQ] = []
                                    
                                    if let query = querySnapshot {
                                        
                                        for doc in query.documents {
                                            let data = doc.data()
                                            if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int, let resultsE = data["resultsE"] as? Int, let resultsF = data["resultsF"] as? Int {
                                                
                                                questions.append(MCQ(question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD, resultsE, resultsF]))
                                            }
                                        }
                                    }
                                    rooms.append(Room(id: doc.documentID, title: data["title"] as! String, questions: questions.isEmpty ? nil : questions, questionCount : data["questionCount"] as! Int))
                                    
                                }
                                group.leave()
                            }
                        }
                        
                        // Wait for all async requests for question data to finish
                        group.wait()
                        
                        DispatchQueue.main.async {

                            // End fetch questions
                            completion(rooms)

                        }
                    }
                    
                } else {
                    completion(nil)
                }
                
            }
            
        }
        
    }
    
    func updateState(roomID: String, state: String, completion: @escaping () -> Void) {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["state" : state])
        
        completion()
        
    }
    
    func updateCurrentQuestion(roomID: String, index: Int, completion: @escaping () -> Void) {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["state" : "active"])
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["currentQuestion" : index])
        
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
    
    func clearResults(roomID: String, questionCount: Int) -> Void {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["userCount" : 0])
        
        if questionCount == 1 {
            db.collection(K.FStore.collectionName).document(roomID).collection("questions").document("0").updateData(["resultsA" : 0, "resultsB" : 0, "resultsC" : 0, "resultsD" : 0, "resultsE" : 0, "resultsF" : 0])
            return
        }
        
        for i in 0...questionCount-1 {
            db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(String(i)).updateData(["resultsA" : 0, "resultsB" : 0, "resultsC" : 0, "resultsD" : 0, "resultsE" : 0, "resultsF" : 0])
        }
        
        
    }
    
    func updateVote(roomID: String, questionIndex: Int, answerIndex: Int, completion: @escaping () -> Void) {
    
        var vote = "resultsA"
        switch answerIndex {
            
        case 1:
            vote = "resultsB"
        case 2:
            vote = "resultsC"
        case 3:
            vote = "resultsD"
        case 4:
            vote = "resultsE"
        case 5:
            vote = "resultsF"
        default:
            break
            
        }
        
        db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(String(questionIndex)).updateData([vote : FieldValue.increment(Int64(1))])
    }
    
    func updateQuestionCount(roomID: String, to: Int, completion: @escaping () -> Void) {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["questionCount" : to])
    }
    
    func deleteRoom(roomID: String, questionCount: Int) {
        for i in 0...questionCount-1 {
            db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(String(i)).delete()
        }
        db.collection(K.FStore.collectionName).document(roomID).delete()
    }
    
    func deleteQuestion(from roomID: String, with index: Int) {
        db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(String(index)).delete()
    }
    
    func addQuestionToRoom(roomID: String, question: String, answerChoices: [String], correctAnswers: [Int], index: Int, time: Double, completion: @escaping () -> Void) {
        
        print("Added question to room")
        if let email = Auth.auth().currentUser?.email {
        
            db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(String(index)).setData(["question": question, "answerChoices": answerChoices, "correctAnswers": correctAnswers, "resultsA" : 0, "resultsB" : 0, "resultsC" : 0, "resultsD" : 0, "resultsE" : 0, "resultsF" : 0, "time": Date().timeIntervalSince1970])
        
            completion()
        }
    }
    
    func reloadQuestion(from roomID: String, with index: Int, completion: @escaping (_ question: MCQ?) -> Void) {
        
        db.collection("rooms").document(roomID).collection("questions").document(String(index)).getDocument { doc, error in
            
            if let doc = doc {
                
                if let data = doc.data() {
                   
                    if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int, let resultsE = data["resultsE"] as? Int, let resultsF = data["resultsF"] as? Int {
                        
                        completion(MCQ(question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD, resultsE, resultsF]))
                    }
                    
                }
                
                
            }
            
        }
        
    }
    
    func reloadQuestions(from roomID: String, completion: @escaping (_ questions: [MCQ]?) -> Void) {
        print(roomID)
        db.collection("rooms").document(roomID).collection("questions").getDocuments { (querySnapshot, error) in
            
            if let e = error {
                
                completion(nil)
                print(e)
            } else {
                
                if let snapshotDocuments = querySnapshot?.documents {
                    
                    var questions: [MCQ] = []
                    
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int, let resultsE = data["resultsE"] as? Int, let resultsF = data["resultsF"] as? Int {
                            
                            questions.append(MCQ(question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD, resultsE, resultsF]))
                            
                            print("MCQ appended")
                        }
                            
                    }
                    
                    completion(questions)
                    
                }
                
            }
        }
        
    }
    
    
}
