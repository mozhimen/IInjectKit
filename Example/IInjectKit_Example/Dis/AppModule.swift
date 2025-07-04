//
//  AppModule.swift
//  IInjectKit_Example
//
//  Created by Taiyou on 2025/7/3.
//
import Foundation
import IInjectKit

struct AppModule{
    @MainActor
    static func inject(){
        @InjectKProvider var counter:Counter = SingleCounter()
    }
}
