//
//  Proxy.swift
//  Ricemill
//
//  Created by marty-suzuki on 2019/08/14.
//  Copyright © 2019 marty-suzuki. All rights reserved.
//

import Combine
import SwiftUI

public struct SubjectProxy<S: Subject> {

    internal let subject: S

    public init(_ subject: S) {
        self.subject = subject
    }

    public func send(_ value: S.Output) {
        subject.send(value)
    }

    public func send(completion: Subscribers.Completion<S.Failure>) {
        subject.send(completion: completion)
    }

    public func send(subscription: Subscription) {
        subject.send(subscription: subscription)
    }
}

extension SubjectProxy where S.Output == Void {

    public func send() {
        subject.send(())
    }
}

@dynamicMemberLookup
public final class InputProxy<Input: InputType> {

    internal let input: Input

    public init(_ input: Input) {
        self.input = input
    }

    public subscript<S: Subject>(dynamicMember keyPath: KeyPath<Input, S>) -> SubjectProxy<S> {
        SubjectProxy(input[keyPath: keyPath])
    }
}

extension InputProxy where Input: BindableInputType {

    public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<Input, Subject>) -> Binding<Subject> {
        ObservedObject(initialValue: input).wrapperValue[dynamicMember: keyPath]
    }
}

@dynamicMemberLookup
public final class OutputProxy<Output: OutputType> {

    internal let output: Output

    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Output, Value>) -> Value {
        output[keyPath: keyPath]
    }

    public subscript<O, E: Error>(dynamicMember keyPath: KeyPath<Output, CurrentValueSubject<O, E>>) -> O {
        output[keyPath: keyPath].value
    }

    public subscript<P: Publisher>(dynamicMember keyPath: KeyPath<Output, P>) -> AnyPublisher<P.Output, P.Failure> {
        output[keyPath: keyPath].eraseToAnyPublisher()
    }

    public init(_ output: Output) {
        self.output = output
    }
}

extension Publisher {

    public func subscribe<S: Subject>(_ proxy: SubjectProxy<S>) -> AnyCancellable where Output == S.Output, Failure == S.Failure {
        subscribe(proxy.subject)
    }
}
