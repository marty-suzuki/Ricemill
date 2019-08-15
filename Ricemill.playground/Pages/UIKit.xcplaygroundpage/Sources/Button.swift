import Combine
import UIKit

public final class Button: UIButton {}

extension Button {

    public final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Button {
        private var subscriber: S?
        private let button: Button

        fileprivate init(subscriber: S, button: Button, event: UIControl.Event) {
            self.subscriber = subscriber
            self.button = button
            button.addTarget(self, action: #selector(didTapButton), for: event)
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            subscriber = nil
        }

        @objc private func didTapButton(_ button: Button) {
            _ = subscriber?.receive(button)
        }
    }

    public struct Publisher: Combine.Publisher {
        public typealias Output = Button
        public typealias Failure = Never

        private let button: Button
        private let controlEvents: UIControl.Event

        fileprivate init(button: Button, events: UIControl.Event) {
            self.button = button
            self.controlEvents = events
        }

        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber, button: button, event: controlEvents)
            subscriber.receive(subscription: subscription)
        }
    }

    public func publisher(for events: UIControl.Event) -> Publisher {
        return Publisher(button: self, events: events)
    }
}
