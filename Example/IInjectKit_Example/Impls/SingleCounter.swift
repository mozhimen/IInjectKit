//
//  SingleCounter.swift
//  IInjectKit_Example
//
//  Created by Taiyou on 2025/7/3.
//

class SingleCounter: Counter {
    private var currentCount: Int = 0
    
    func increment() -> Int {
        currentCount += 1
        return currentCount
    }
    
    func reset() {
        currentCount = 0
    }
}
