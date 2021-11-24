//
//  MCQ.swift
//  Leo
//
//  Created by Kai Stout on 7/27/21.
//

import Foundation

struct MCQ: Equatable {
    
    let id: String
    
    let index: Int
    
    let question: String
    
    let answerChoices: [String]
    
    let correctAnswers: [Int]
    
    let results: [Int]
    
    static func == (mcq1: MCQ, mcq2: MCQ) -> Bool {
        return mcq1.question == mcq2.question && mcq1.answerChoices.elementsEqual(mcq2.answerChoices) && mcq1.correctAnswers.elementsEqual(mcq2.correctAnswers)
    }
    
}
