//
//  Publishing.swift
//  Ricemill
//
//  Created by marty-suzuki on 2019/08/14.
//  Copyright © 2019 marty-suzuki. All rights reserved.
//

import Combine
import SwiftUI

@dynamicMemberLookup
public final class Publishing<Input: InputType> {

    private let input: Input

    internal init(_ input: Input) {
        self.input = input
    }

    public subscript<P: Publisher>(dynamicMember keyPath: KeyPath<Input, P>) -> AnyPublisher<P.Output, P.Failure> {
        input[keyPath: keyPath].eraseToAnyPublisher()
    }
}

extension Publishing where Input: BindableInputType {

    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Input, Value>) -> Value {
        input[keyPath: keyPath]
    }
}
