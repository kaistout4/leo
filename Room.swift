//
//  Room.swift
//  Leo
//
//  Created by Kai Stout on 7/21/21.
//

import Foundation

class Room {
    
    let ID: String
    var title: String
    var questions: [MCQ]?
    var questionCount: Int
    
    init(id: String, title: String, questionCount: Int) {
        
        self.questionCount = questionCount
        self.ID = id
        self.title = title
        
    }
    
    
   
    
    
}
