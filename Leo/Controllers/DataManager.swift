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
                
        db.collection(K.FStore.collectionName).whereField("user", isEqualTo: user).order(by: "time").getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
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
                            
                            self.db.collection("rooms").document(doc.documentID).collection("questions").order(by: "index").getDocuments { querySnapshot, error in
                                
                                if let e = error {
                                    print(e)
                                    
                                } else {
                                    
                                    var questions: [MCQ] = []
                                    
                                    if let query = querySnapshot {
                                        
                                        for doc in query.documents {
                                            let data = doc.data()
                                            if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int, let resultsE = data["resultsE"] as? Int, let resultsF = data["resultsF"] as? Int, let index = data["index"] as? Int {
                                                print("Appending question to array")
                                                questions.append(MCQ(id: doc.documentID, index: index, question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD, resultsE, resultsF]))
                                            }
                                        }
                                    }
                                    rooms.append(Room(id: doc.documentID, title: data["title"] as! String, questions: questions.isEmpty ? nil : questions, questionCount : data["questionCount"] as! Int))
                                    print(questions)
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
    
    func rename(roomID: String, newName: String) {
        db.collection(K.FStore.collectionName).document(roomID).updateData(["title" : newName])
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
    
    func clearResults(roomID: String) -> Void {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["userCount" : 0])
        
        db.collection(K.FStore.collectionName).document(roomID).collection("questions").getDocuments { (querySnapshot, error) in
            if let query = querySnapshot {
                let docs = query.documents
                for doc in docs {
                    doc.reference.updateData(["resultsA" : 0, "resultsB" : 0, "resultsC" : 0, "resultsD" : 0, "resultsE" : 0, "resultsF" : 0])
                }
            }
        }
        
    }
    
    func updateVote(roomID: String, questionIndex: Int, answerIndex: Int, by: Int, completion: @escaping () -> Void) {
    
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
        db.collection(K.FStore.collectionName).document(roomID).collection("questions").order(by: "index").getDocuments { (querySnapshot, error) in
            if let query = querySnapshot {
                let docs = query.documents
                docs[questionIndex].reference.updateData([vote : FieldValue.increment(Int64(by))])
            }
        }
    }
    
    func updateQuestionCount(roomID: String, to: Int, completion: @escaping () -> Void) {
        
        db.collection(K.FStore.collectionName).document(roomID).updateData(["questionCount" : to])
    }
    
    func incrementUserCount(roomID: String) {
        db.collection(K.FStore.collectionName).document(roomID).updateData(["userCount" : FieldValue.increment(Int64(1))])
    }
    
    func decrementUserCount(roomID: String) {
        db.collection(K.FStore.collectionName).document(roomID).updateData(["userCount" : FieldValue.increment(Int64(-1))])
    }
    
    //func decrementUserCount9
    
    func deleteQuestionsFromRoom(roomID: String, questionCount: Int) {
        if questionCount != 0 {
            db.collection(K.FStore.collectionName).document(roomID).collection("questions").order(by: "index").getDocuments { (querySnapshot, error) in
                if let query = querySnapshot {
                    let docs = query.documents
                    print(docs.count)
                    for doc in docs {
                        print("Deleting document")
                        doc.reference.delete()
                    }
                }
            }
        }
    }
    
    func deleteRoom(roomID: String, questionCount: Int) {
        if questionCount != 0 {
            db.collection(K.FStore.collectionName).document(roomID).collection("questions").getDocuments { (querySnapshot, error) in
                if let query = querySnapshot {
                    let docs = query.documents
                    print(docs.count)
                    for doc in docs {
                        print("Deleting document")
                        doc.reference.delete()
                    }
                }
            }
        }
        
        db.collection(K.FStore.collectionName).document(roomID).delete()
    }
    
    func deleteQuestion(from roomID: String, id: String) {
        db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(id).delete()
    }
    
    func addQuestionToRoom(id: String, index: Int, roomID: String, question: String, answerChoices: [String], correctAnswers: [Int], time: Double, completion: @escaping () -> Void) {

        db.collection(K.FStore.collectionName).document(roomID).collection("questions").document(id).setData(["id": id, "index" : index, "question": question, "answerChoices": answerChoices, "correctAnswers": correctAnswers, "resultsA" : 0, "resultsB" : 0, "resultsC" : 0, "resultsD" : 0, "resultsE" : 0, "resultsF" : 0, "time": Date().timeIntervalSince1970])
            completion()

    }
    
    func reloadQuestion(from roomID: String, with index: Int, completion: @escaping (_ question: MCQ?) -> Void) {
        
        db.collection("rooms").document(roomID).collection("questions").order(by: "index").getDocuments { (querySnapshot, error) in
            if let query = querySnapshot {
                let docs = query.documents
                let doc = docs[index].reference
                doc.getDocument { (doc, error) in
                    if let doc = doc {
                        if let data = doc.data() {
                            if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int, let resultsE = data["resultsE"] as? Int, let resultsF = data["resultsF"] as? Int, let index = data["index"] as? Int {
                                
                                completion(MCQ(id: doc.documentID, index: index, question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD, resultsE, resultsF]))
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func reloadQuestions(from roomID: String, completion: @escaping (_ questions: [MCQ]?) -> Void) {
        print(roomID)
        db.collection("rooms").document(roomID).collection("questions").order(by: "index").getDocuments { (querySnapshot, error) in
            
            if let e = error {
                
                completion(nil)
                print(e)
            } else {
                
                if let snapshotDocuments = querySnapshot?.documents {
                    
                    var questions: [MCQ] = []
                    
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        if let question = data["question"] as? String, let answerChoices = data["answerChoices"] as? [String], let correctAnswers = data["correctAnswers"] as? [Int], let resultsA = data["resultsA"] as? Int, let resultsB = data["resultsB"] as? Int, let resultsC = data["resultsC"] as? Int, let resultsD = data["resultsD"] as? Int, let resultsE = data["resultsE"] as? Int, let resultsF = data["resultsF"] as? Int, let index = data["index"] as? Int {
                            
                            questions.append(MCQ(id: doc.documentID, index: index, question: question, answerChoices: answerChoices, correctAnswers: correctAnswers, results: [resultsA, resultsB, resultsC, resultsD, resultsE, resultsF]))
                            
                            print("MCQ appended")
                        }
                            
                    }
                    
                    completion(questions)
                    
                }
                
            }
        }
        
    }
    
    
}
