//
//  ContentView.swift
//  IInjectKit_Example
//
//  Created by Taiyou on 2025/7/3.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm:MainViewModel = MainViewModel()
    
    var body: some View {
        VStack {
            Text("\(vm.count)")
                .font(.largeTitle)
            Button{
                vm.increment()
            }label: {
                Text("Increment")
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView()
}
