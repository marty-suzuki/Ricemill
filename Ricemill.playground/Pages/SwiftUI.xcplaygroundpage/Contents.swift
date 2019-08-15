/*:
# SwiftUI Sample

**Please build Ricemill framework with iOS simulator before you run this playground.**

#### Classes
- CounterView
- ViewModel
*/
//: You can try [UIKit Sample](@next).

import Combine
import PlaygroundSupport
import Ricemill
import SwiftUI

struct CounterView: View {

    @ObservedObject var viewModel = ViewModel.make()

    var body: some View {
        VStack {
            Button(
                action: { self.viewModel.input.increment.send() },
                label: { Text("🔼") }
                )
                .disabled(!viewModel.output.isIncrementEnabled)
                .opacity(viewModel.output.isIncrementEnabled ? 1 : 0.5)
            Text("\(viewModel.output.count)")
            Button(
                action: { self.viewModel.input.decrement.send() },
                label: { Text("🔽") }
                )
                .disabled(!viewModel.output.isDecrementEnabled)
                .opacity(viewModel.output.isDecrementEnabled ? 1 : 0.5)
            Toggle(
                isOn: viewModel.input.isOn,
                label: { Text(self.viewModel.output.toggleText) }
                )
                .frame(width: 150, alignment: .center)
        }
    }
}

final class ViewModel: Machine<ViewModel.Resolver> {

    static func make() -> ViewModel {
        return ViewModel(input: Input(),
                         store: Store(),
                         extra: Extra())
    }

    typealias Output = Store

    final class Input: BindableInputType {
        let increment = PassthroughSubject<Void, Never>()
        let decrement = PassthroughSubject<Void, Never>()
        @Published var isOn = false
    }

    final class Store: StoredOutputType {
        @Published var count: Int = 0
        @Published var isIncrementEnabled = false
        @Published var isDecrementEnabled = false
        @Published var toggleText = ""
    }

    struct Extra: ExtraType {}

    enum Resolver: ResolverType {

        static func polish(input: Publishing<Input>,
                           store: Store,
                           extra: Extra) -> Polished<Output> {

            var cancellables: [AnyCancellable] = []

            do {
                let increment = input.increment
                    .flatMap { _ in Just(store.count) }
                    .map { $0 + 1 }

                let decrement = input.decrement
                    .flatMap { _ in Just(store.count) }
                    .map { $0 > 0 ? $0 - 1 : $0 }

                increment.merge(with: decrement)
                    .assign(to: \.count, on: store)
                    .store(in: &cancellables)
            }

            input.$isOn
                .assign(to: \.isIncrementEnabled, on: store)
                .store(in: &cancellables)

            input.$isOn
                .combineLatest(store.$count)
                .map { $0 && $1 > 0 }
                .assign(to: \.isDecrementEnabled, on: store)
                .store(in: &cancellables)

            input.$isOn
                .map { $0 ? "Enabled" : "Disabled" }
                .assign(to: \.toggleText, on: store)
                .store(in: &cancellables)

            return Polished(cancellables: cancellables)
        }
    }
}


PlaygroundPage.current.liveView = UIHostingController(rootView: CounterView())
