//
//  IInjectKit_ExampleApp.swift
//  IInjectKit_Example
//
//  Created by Taiyou on 2025/7/3.
//

import SwiftUI

@main
struct IInjectKit_ExampleApp: App {
    init() {
        AppModule.inject()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
