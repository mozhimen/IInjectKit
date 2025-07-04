# IInjectKit
IOS依赖注入库


本文是我之前关于自动依赖注入 （DI） 的文章的延续，因此我不会深入探讨依赖注入本身，而是深入探讨 Swift 6 上的自动依赖注入 （DI） 实现。在阅读了一些回复后，我写下了这篇文章，这些回复询问我如何更新实现以遵循 Swift 6 严格并发，所以让我们来分解一下。如果你来到这里，但想深入研究依赖注入 （DI） 理论，请查看我之前的文章：

Swift 应用程序的自动依赖关系注入 （DI） 使您的代码干净
Swift 中的自动依赖关系注入 （DI）
medium.com

介绍
依赖关系注入 （DI）
依赖关系注入 （DI） 是面向对象编程 （OOP） 中最流行的设计模式。它是一种技术，当另一个对象依赖于它时，管理对象的创建方式。依赖注入的概念本身非常简单，有一个对象依赖于一个或多个依赖，然后将依赖注入到依赖对象中，而不是在对象内部创建它。

自动依赖关系注入 （DI）
自动依赖注入 （DI），基本上是依赖注入，但注入过程是自动化的。使用 Automatic DI，开发人员不必手动注入依赖项，也无需担心在何处以及如何注入依赖项。

实现
让我们不要浪费更多时间，直接进行实施。这次我将编写一个更全面的指南，以使代码 / 实现更易于理解。让我们使用具有 MVVM 体系结构模式的计数器应用程序作为案例。

1. 创建帮助程序类（也称为 injector）。
让我们从 injector（辅助类）开始，因为没有它，我们就无法进行自动依赖注入。这与我在上一篇文章中的实现非常相似，只是符合 Swift 6。

@Inject用于注入依赖项。
@Provider用于提供依赖项。
import Foundation

@MainActor // Use this to perform the injection on Main Thread following Swift 6 Strict Concurrency
struct DependenciesInjector{
    private var dependencyList: [String:Any] = [:]
    static var shared = DependenciesInjector()
    
    private init() {  }
    
    func resolve<T>()-> T{
        guard let t = dependencyList[String(describing: T.self)] as? T else {
            fatalError("No povider registered for type \(T.self)")
        }
        return t
    }
    
    mutating func register<T>(dependency : T){
        dependencyList[String(describing: T.self)] = dependency
    }
}

@MainActor
@propertyWrapper struct Inject<T> {
    var wrappedValue: T
    
    init() {
        self.wrappedValue = DependenciesInjector.shared.resolve()
    }
}

@MainActor
@propertyWrapper struct Provider<T> {
    var wrappedValue: T
    
    init(wrappedValue: T) {
        self.wrappedValue = wrappedValue
        DependenciesInjector.shared.register(dependency: wrappedValue)
    }
}
2. 为我们的应用程序创建 Counter 模型。
在我们注入依赖项之前，我们当然必须先创建依赖项。因此，让我们创建自己的 Counter 模型。我将使用一个协议，并创建实际的实现，以向您展示通过此实现，我们可以遵循 S.O.L.I.D 原则中的依赖反转原则。

协议 （蓝图）。
import Foundation

protocol Counter {
    func increment() -> Int
    func reset()
}
实现
import Foundation

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
3. 提供依赖项。
现在我们手头有依赖项，我们必须提供依赖项，以便以后可以注入它。要提供依赖项，我们可以创建一个 模块，并提供我们的应用程序使用的所有依赖项。在这种情况下，我只创建了一个 App Module，但你可以根据你的 App 需求进行调整，比如说如果有很多依赖，你可以把它拆分成多个 Module。

要提供依赖项，请在 .@Providervar

import Foundation

struct AppModule {
    @MainActor // Use this to perform the injection on Main Thread following Swift 6 Strict Concurrency
    static func inject() {
        @Provider var counter: Counter = SingleCounter()

        /// ...Inject any others dependencies
    }
}
目前还没有提供，现在我们必须在 App Initialization 上调用 module 的方法，以向 app 提供所有依赖项。inject()

import SwiftUI

@main
struct DependencyInjectorApp: App {
    init() {
        AppModule.inject() // Provides all the dependencies
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
4. 创建 ViewModel。
现在我们得到了所需的一切，所有的依赖项都已提供，我们可以开始创建 ViewModel 并设置注入。

我们不必再创建对象，只需使用 before ，并确保定义类型注释，依赖项将自动注入到变量中。@Injectvar

import Foundation

class MainViewModel: ObservableObject {
    @Inject var counter: Counter
    @Published var count: Int = 0
    
    deinit {
        DispatchQueue.main.sync { // Required to run @MainActor task in deinit
            counter.reset() // Reset the counter when leaving screen or VM deinitialization
        }
    }
    
    func increment() {
        count = counter.increment()
    }
}
如果我们需要在 内部调用方法，其中 Main-Actor 隔离属性无法从非隔离上下文引用，我们可以在 内部进行调用 。deinitDispatchQueue.main.sync

5. 用户界面
现在一切都已经设置好了，让我们创建一个简单的 UI 来演示所有功能。至于 ViewModel，我们不必为此进行自动依赖注入甚至普通的依赖注入，我们可以直接在 View 上使用 创建它。@StateObject

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: MainViewModel = MainViewModel()
    
    var body: some View {
        VStack {
            Text("\(viewModel.count)")
                .font(.largeTitle)
            
            Button {
                viewModel.increment()
            } label: {
                Text("Increment")
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ContentView()
}
㯱
这是一个结束！如果你在这里，我假设你刚刚完成了教程或文章，希望这篇文章可以帮助你满足开发所需的内容。如果你读过我之前关于自动依赖注入 （DI） 的文章，那么你一定已经注意到了，实现方式非常相似，光是这篇文章我写了一个与 Swift 6 Strict Currency 配合得很好的实现，以及一个全面的教程，使其更容易理解。在处理大型代码库或大型项目时，您会感觉到自动管理依赖项是多么有帮助，我们不必担心如何将依赖项注入到需要它的对象中。
