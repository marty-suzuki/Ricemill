//
//  MachineType.swift
//  Ricemill
//
//  Created by marty-suzuki on 2021/03/31.
//

public protocol MachineType: AnyObject {
    associatedtype Input: InputType
    associatedtype Output: OutputType
    var input: InputProxy<Input> { get }
    var output: OutputProxy<Output> { get }
}
