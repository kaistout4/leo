//
//  MCQ.swift
//  Leo
//
//  Created by Kai Stout on 7/27/21.
//

import Foundation

struct MCQ: Codable {
    
    let question: String
    
    let answerChoices: [String]
    
    let correctAnswers: [Int]
    
    let results: [Int]

    
}
