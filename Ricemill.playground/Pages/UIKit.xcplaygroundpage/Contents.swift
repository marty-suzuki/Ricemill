/*:
# UIKit Sample

**Please build Ricemill framework with iOS simulator before you run this playground.**

#### Classes
- CounterViewController
- ViewModel
*/
//: You can try [SwiftUI Sample](@previous).

import Combine
import PlaygroundSupport
import Ricemill
import UIKit

final class CounterViewController: UIViewController {

    let incrementButton: Button = {
        let button = Button(type: .system)
        button.setTitle("🔼", for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let decrementButton: Button = {
        let button = Button(type: .system)
        button.setTitle("🔽", for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let countLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let counterToggle: Toggle = {
        let toggle = Toggle()
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()

    let counterStateLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let viewModel = ViewModel.make()

    private var cancellables: [AnyCancellable] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        do {
            view.backgroundColor = .white

            let verticalStackView: UIStackView = {
                let stackView = UIStackView(arrangedSubviews: [
                    incrementButton,
                    countLabel,
                    decrementButton,
                ])
                stackView.axis = .vertical
                stackView.translatesAutoresizingMaskIntoConstraints = false
                return stackView
            }()

            view.addSubview(verticalStackView)
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: verticalStackView.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: verticalStackView.centerYAnchor),
            ])

            let horizontalStackView: UIStackView = {
                let stackView = UIStackView(arrangedSubviews: [
                    counterStateLabel,
                    counterToggle,
                ])
                stackView.spacing = 8
                stackView.axis = .horizontal
                stackView.translatesAutoresizingMaskIntoConstraints = false
                return stackView
            }()

            verticalStackView.addArrangedSubview(horizontalStackView)
        }

        do {
            let output = viewModel.output

            output.count
                .assign(to: \.text, on: countLabel)
                .store(in: &cancellables)

            output.isIncrementEnabled
                .assign(to: \.isEnabled, on: incrementButton)
                .store(in: &cancellables)

            output.isDecrementEnabled
                .assign(to: \.isEnabled, on: decrementButton)
                .store(in: &cancellables)

            output.isIncrementEnabled
                .map { $0 ? 1 : 0.5 }
                .assign(to: \.alpha, on: incrementButton)
                .store(in: &cancellables)

            output.isDecrementEnabled
                .map { $0 ? 1 : 0.5 }
                .assign(to: \.alpha, on: decrementButton)
                .store(in: &cancellables)

            output.toggleText
                .assign(to: \.text, on: counterStateLabel)
                .store(in: &cancellables)

        }

        do {
            let input = viewModel.input

            incrementButton.publisher(for: .touchUpInside)
                .map { _ in () }
                .subscribe(input.increment)
                .store(in: &cancellables)

            decrementButton.publisher(for: .touchUpInside)
                .map { _ in () }
                .subscribe(input.decrement)
                .store(in: &cancellables)

            counterToggle.publisher()
                .subscribe(input.isOn)
                .store(in: &cancellables)
        }
    }
}

final class ViewModel: Machine<ViewModel.Resolver> {

    static func make() -> ViewModel {
        return ViewModel(input: Input(), store: Store(), extra: Extra())
    }

    struct Input: InputType {
        let increment = PassthroughSubject<Void, Never>()
        let decrement = PassthroughSubject<Void, Never>()
        let isOn = PassthroughSubject<Bool, Never>()
    }

    struct Output: OutputType {
        let count: AnyPublisher<String?, Never>
        let isIncrementEnabled: AnyPublisher<Bool, Never>
        let isDecrementEnabled: AnyPublisher<Bool, Never>
        let toggleText: AnyPublisher<String?, Never>
    }

    final class Store: StoreType {
        @Published var count: Int = 0
        @Published var isToggleEnabled = false
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

            input.isOn
                .assign(to: \.isToggleEnabled, on: store)
                .store(in: &cancellables)

            let count = store.$count
                .map(String.init)
                .map(Optional.some)
                .eraseToAnyPublisher()

            let incrementEnabled = store.$isToggleEnabled
                .eraseToAnyPublisher()

            let isDecrementEnabled = store.$isToggleEnabled
                .combineLatest(store.$count)
                .map { $0 && $1 > 0 }
                .eraseToAnyPublisher()

            let toggleText = store.$isToggleEnabled
                .map { $0 ? "Enabled" : "Disabled" }
                .map(Optional.some)
                .eraseToAnyPublisher()

            return Polished(output: Output(count: count,
                                           isIncrementEnabled: incrementEnabled,
                                           isDecrementEnabled: isDecrementEnabled,
                                           toggleText: toggleText),
                            cancellables: cancellables)
        }
    }
}

PlaygroundPage.current.liveView = CounterViewController()
