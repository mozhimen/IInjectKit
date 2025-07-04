//
//  File.swift
//  MyLibrary
//
//  Created by Taiyou on 2025/7/3.
//

import Foundation

@MainActor
struct DependenciesResolver{
    private var dependencyList:[String:Any] = [:]
    static var shared = DependenciesResolver()
    
    private init(){}
    
    func resolve<T>() -> T{
        guard let t = dependencyList[String(describing: T.self)] as? T else {
            fatalError("No provider register for type \(T.self)")
        }
        return t
    }
    
    mutating func register<T>(dependency:T){
        dependencyList[String(describing: T.self)] = dependency
    }
}

@MainActor
@propertyWrapper
public struct InjectKInjector<T> {
    public var wrappedValue:T
    
    public init(){
        self.wrappedValue = DependenciesResolver.shared.resolve()
    }
}

@MainActor
@propertyWrapper
public struct InjectKProvider<T>{
    public var wrappedValue:T
    
    public init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        DependenciesResolver.shared.register(dependency: wrappedValue)
    }
}
