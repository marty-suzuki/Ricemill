//
//  Proxy.swift
//  Ricemill
//
//  Created by marty-suzuki on 2019/08/14.
//  Copyright © 2019 marty-suzuki. All rights reserved.
//

import Combine
import SwiftUI

/// Proxy of Combine.Subject
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

/// Limitates access level of Input
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

    /// Returns `Binding<Subject>` when Input is BindableInputType
    /// - note: Assumed to be the difinition is @Published var string = "" for example.
    public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<Input, Subject>) -> Binding<Subject> {
        ObservedObject(initialValue: input).projectedValue[dynamicMember: keyPath]
    }
}

/// Limitates access level of Output
@dynamicMemberLookup
public final class OutputProxy<Output: OutputType> {

    internal let output: Output

    public init(_ output: Output) {
        self.output = output
    }

    /// - note: Assumed to be the difinition is @Published var string = "" for example.
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Output, Value>) -> Value {
        output[keyPath: keyPath]
    }

    public subscript<O, E: Error>(dynamicMember keyPath: KeyPath<Output, CurrentValueSubject<O, E>>) -> O {
        output[keyPath: keyPath].value
    }

    public subscript<P: Publisher>(dynamicMember keyPath: KeyPath<Output, P>) -> AnyPublisher<P.Output, P.Failure> {
        output[keyPath: keyPath].eraseToAnyPublisher()
    }
}

extension OutputProxy where Output: StoredOutputType {

    /// Returns `Binding<Subject>` when Output is StoredOutputType
    /// - note: Assumed to be the difinition is @Published var isHidden = false for example.
    public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<Output, Subject>) -> Binding<Subject> {
        ObservedObject(initialValue: output).projectedValue[dynamicMember: keyPath]
    }
}


extension Publisher {

    public func subscribe<S: Subject>(_ proxy: SubjectProxy<S>) -> AnyCancellable where Output == S.Output, Failure == S.Failure {
        subscribe(proxy.subject)
    }
}
