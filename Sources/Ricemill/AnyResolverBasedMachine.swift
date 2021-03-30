//
//  AnyResolverBasedMachine.swift
//  Ricemill
//
//  Created by marty-suzuki on 2021/03/31.
//

import Combine

public typealias Machine<Resolver: ResolverType> = AnyResolverBasedMachine<Resolver.Input, Resolver.Output> & ResolverType

/// A type which have ResolverType based initializer.
public protocol AnyResolverBasedMachineType: MachineType {
    init<Resolver: ResolverType>(
        input: Resolver.Input,
        store: Resolver.Store,
        extra: Resolver.Extra,
        resolver _: Resolver.Type
    ) where Input == Resolver.Input, Output == Resolver.Output
}

extension AnyResolverBasedMachineType where Self: ResolverType {
    public init(input: Input, store: Store, extra: Extra) {
        self.init(input: input, store: store, extra: extra, resolver: Self.self)
    }
}

/// A type-erased wrapper which have ResolverType based initializer.
open class AnyResolverBasedMachine<Input: InputType, Output: OutputType>: AnyResolverBasedMachineType {
    public let input: InputProxy<Input>
    public let output: OutputProxy<Output>
    
    /// Strong reference to the actual machine for preventing it being released.
    private let _machine: AnyObject
    
    required public init<Resolver: ResolverType>(
        input: Resolver.Input,
        store: Resolver.Store,
        extra: Resolver.Extra,
        resolver _: Resolver.Type
    ) where Input == Resolver.Input, Output == Resolver.Output {
        let machine = PrimitiveMachine<Resolver>(input: input, store: store, extra: extra)
        self.input = machine.input
        self.output = machine.output
        self._machine = machine
    }
}

extension AnyResolverBasedMachine: ObservableObject where Output: StoredOutputType {

    public var objectWillChange: AnyPublisher<Output.ObjectWillChangePublisher.Output, Never> {
        output.objectWillChange
    }
}
