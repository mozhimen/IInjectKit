//
//  MainViewModel.swift
//  IInjectKit_Example
//
//  Created by Taiyou on 2025/7/3.
//
import IInjectKit
import Foundation
public class MainViewModel:ObservableObject{
    @InjectKInjector var counter:Counter
    @Published var count:Int = 0
    
    deinit {
        DispatchQueue.main.sync(execute: {
            counter.reset()
        })
    }
    
    func increment(){
        count = counter.increment()
    }
}
