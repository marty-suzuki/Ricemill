# Ricemill

🌾 ♻️ 🍚 Unidirectional Input / Output framework with Combine.

| [SwiftUI Playground](https://github.com/marty-suzuki/Ricemill/blob/master/Ricemill.playground/Pages/SwiftUI.xcplaygroundpage/Contents.swift) | [UIKit Playground](https://github.com/marty-suzuki/Ricemill/blob/master/Ricemill.playground/Pages/UIKit.xcplaygroundpage/Contents.swift) |
| :-: | :-: |
| ![SwiftUI](https://user-images.githubusercontent.com/2082134/63072558-68a5b780-bf5f-11e9-81e8-d25798ec29da.gif) | ![UIKit](https://user-images.githubusercontent.com/2082134/63072557-67748a80-bf5f-11e9-9f9f-fe6510421340.gif) |

# About Ricemill

Ricemill represents unidirectional data flow with these components.

- [Input](#input)
- [Output](#output)
- [Store](#store)
- [Extra](#extra)
- [Resolver](#resolver)
- [Machine](#machine)

### Input

The rule of Input is having Subject properties that are defined internal scope.

```swift
struct Input: InputType {
    let increment = PassthroughSubject<Void, Never>()
    let isOn = PassthroughSubject<Bool, Never>()
}
```

Properties of Input are defined internal scope. But these return `SubjectProxy` via dynamicMemberLookup if Input is wrapped with InputProxy.

```swift
let input: InputProxy<Input>
let increment: SubjectProxy<Void> = input.increment
increment.send()
let isOn: SubjectProxy<Bool> = input.isOn
isOn.send(true)
```

### Output

The rule of Output is having Publisher or `@Published` properties that are defined internal scope.

```swift
class Output: OutputType {
    let count: AnyPublisher<String?, Never>
    @Published var isIncrementEnabled: Bool
}
```

### Store

The rule of Store is having inner states.

```swift
class Store: StoreType {
    @Published var count = 0
    @Published var isIncrementEnabled: Bool = false
}
```

### Extra

The rule of Extra is having other dependencies.

### Resolver

The rule of Resolver is generating Output from Input, Store and Extra. It generates Output to call `static func polish(input:store:extra:)`. `static func polish(input:store:extra:)` is called once when Machine is initialized.

```swift
enum Resolver: ResolverType {
    typealias Input = ViewModel.Input
    typealias Output = ViewModel.Output
    typealias Store = ViewModel.Store
    typealias Extra = ViewModel.Extra

    static func polish(input: Publishing<Input>, store: Store, extra: Extra) -> Polished<Output> {
        ...                         
    }
}
```

Here is a exmaple of implementation of `static func polish(input:store:extra:)`.

```swift
extension ViewModel.Resolver {

    static func polish(input: Publishing<Input>,
                       store: Store,
                       extra: Extra) -> Polished<Output> {

         var cancellables: [AnyCancellable] = []

         let increment = input.increment
             .flatMap { _ in Just(store.count) }
             .map { $0 + 1 }

         increment.merge(with: decrement)
             .assign(to: \.count, on: store)
             .store(in: &cancellables)

         let count = store.$count
             .map(String.init)
             .map(Optional.some)
             .eraseToAnyPublisher()

         return Polished(output: Output(count: count),
                         cancellables: cancellables)
      }
}
```

### Machine

Machine represents ViewModels of MVVM (it can also be used as Models). It has `input: InputProxy<Input>` and `output: OutputProxy<Output>`. It automatically generates `input: InputProxy<Input>` and `output: OutputProxy<Output>` from instances of [Input](#input), [Store](#store), [Extra](#extra) and [Resolver](#resolver).

#### SwiftUI Usage

If Input implements `BindableInputType`, can access value as `Binding<Value>` from outside.
In addition, if Output equals Store and implements `StoredOutputType`, can access primitive value and Publisher from outside.
Sample implementaion is here.

```swift
extension ViewModel {
    typealias Output = Store

    final class Input: BindableInputType {
        let increment = PassthroughSubject<Void, Never>()
        @Published var isOn = false
    }

    final class Store: StoredOutputType {
        @Published var count: Int = 0
    }
}

let viewModel: ViewModel = ...
viewModel.input.isOn    // This is `Binding<Bool>` instance.
viewModel.output.count  // This is `Int` instance.
viewModel.output.$count // This is `Published<Int>.Publisher` instance.
```

# Requirement

- Xcode 11 Beta 5
- macOS 10.15
- iOS 13.0
- tvOS 13.0
- watchOS 6.0

# Sister library

- [cats-oss/Unio](https://github.com/cats-oss/Unio)

# License

Ricemill is released under the MIT License.
