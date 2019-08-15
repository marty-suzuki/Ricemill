//
//  Polished.swift
//  Ricemill
//
//  Created by marty-suzuki on 2019/08/15.
//  Copyright © 2019 marty-suzuki. All rights reserved.
//

import Combine

public struct Polished<Output> {
    internal let output: Output?
    internal let cancellables: [AnyCancellable]
}

extension Polished where Output: StoreType {

    public init(cancellables: [AnyCancellable]) {
        self.output = nil
        self.cancellables = cancellables
    }
}

extension Polished where Output: OutputType {

    public init(output: Output, cancellables: [AnyCancellable]) {
        self.output = output
        self.cancellables = cancellables
    }
}
