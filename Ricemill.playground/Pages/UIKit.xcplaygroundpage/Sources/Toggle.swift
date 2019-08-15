import Combine
import UIKit

public final class Toggle: UISwitch {}

extension Toggle {

    public final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Bool {
        private var subscriber: S?
        private let toggle: Toggle

        fileprivate init(subscriber: S, toggle: Toggle) {
            self.subscriber = subscriber
            self.toggle = toggle
            toggle.addTarget(self, action: #selector(didChangeToggle), for: .valueChanged)
        }

        public func request(_ demand: Subscribers.Demand) {}

        public func cancel() {
            subscriber = nil
        }

        @objc private func didChangeToggle(_ toggle: Toggle) {
            _ = subscriber?.receive(toggle.isOn)
        }
    }

    public struct Publisher: Combine.Publisher {
        public typealias Output = Bool
        public typealias Failure = Never

        private let toggle: Toggle

        fileprivate init(toggle: Toggle) {
            self.toggle = toggle
        }

        public func receive<S>(subscriber: S) where S : Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber, toggle: toggle)
            subscriber.receive(subscription: subscription)
        }
    }

    public func publisher() -> Publisher {
        return Publisher(toggle: self)
    }
}
