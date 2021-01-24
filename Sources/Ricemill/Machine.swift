//
//  Machine.swift
//  Ricemill
//
//  Created by marty-suzuki on 2019/08/14.
//  Copyright © 2019 marty-suzuki. All rights reserved.
//

import Combine

/// Represents Output of Machine.
public protocol OutputType {}

/// Represents Input of Machine.
public protocol InputType {}

/// Represents store retained by Machine.
public protocol StoreType: ObservableObject {}

/// Represents extra dependencies of Machine.
public protocol ExtraType {}

/// Represents Input of Machine has Biniding<Value>.
/// - note: In SwiftUI case, this will be used.
public protocol BindableInputType: InputType, ObservableObject {}

/// Represents Store and Output of Machine.
/// - note: In SwiftUI case, this will be used.
public protocol StoredOutputType: OutputType, StoreType {}

/// Represents definitions and implementations of Machine.
public protocol ResolverType {
    associatedtype Input: InputType
    associatedtype Output: OutputType
    associatedtype Store: StoreType
    associatedtype Extra: ExtraType

    /// Generates Output.
    ///
    /// - note: This method called once when a linked Machine is initialized.
    static func polish(input: Publishing<Input>, store: Store, extra: Extra) -> Polished<Output>
}

/// Makes possible to implement Unidirectional input / output.
open class Machine<Resolver: ResolverType> {

    public let input: InputProxy<Resolver.Input>
    public let output: OutputProxy<Resolver.Output>

    private let _extra: Resolver.Extra
    private let _store: Resolver.Store
    private let _cancellables: [AnyCancellable]

    public init(input: Resolver.Input,
                output: Resolver.Output,
                store: Resolver.Store,
                extra: Resolver.Extra,
                cancellables: [AnyCancellable]) {
        self.input = InputProxy(input)
        self.output = OutputProxy(output)
        self._store = store
        self._extra = extra
        self._cancellables = cancellables
    }

    public convenience init(input: Resolver.Input, store: Resolver.Store, extra: Resolver.Extra) {
        let receivableInput = Publishing(input)
        let polished = Resolver.polish(input: receivableInput, store: store, extra: extra)
        self.init(input: input,
                  output: polished.output ?? { fatalError("Must set output when `Output` doesn't equal `Store`.") }(),
                  store: store,
                  extra: extra,
                  cancellables: polished.cancellables)
    }
}

extension Machine: ObservableObject where Resolver.Output == Resolver.Store {

    public var objectWillChange: Resolver.Store.ObjectWillChangePublisher {
        return _store.objectWillChange
    }

    /// - note: When Resolver.Output equals Resolver.Store, this initializer is available.
    public convenience init(input: Resolver.Input, store: Resolver.Store, extra: Resolver.Extra) {
        let receivableInput = Publishing(input)
        let polished = Resolver.polish(input: receivableInput, store: store, extra: extra)
        self.init(input: input,
                  output: store,
                  store: store,
                  extra: extra,
                  cancellables: polished.cancellables)
    }
}
