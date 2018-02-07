//
//  AttributesConfigurator.swift
//  BCMarkdown
//
//  Created by wl on 17/08/2017.
//  Copyright © 2017 Beary Innovative. All rights reserved.
//

import Foundation

protocol Stack {
    associatedtype Element
    mutating func push(_ x: Element)
    mutating func pop() -> Element?
    func peek() -> Element?
}

struct AttributesConfigurator: Stack {
    var _stack: [Attributes] = [] {
        didSet { _combineAttributes = nil }
    }
    var _combineAttributes: Attributes?

    init() {}

    mutating func push(_ x: Attributes) { _stack.push(x) }

    @discardableResult
    mutating func pop() -> Attributes? { return _stack.pop() }
    mutating func empty() { _stack.removeAll() }
    func peek() -> Attributes? { return _stack.peek() }

    mutating func combineAttributes() -> Attributes {
        if let attrs = _combineAttributes { return attrs }
        _combineAttributes = [:]
        _stack.forEach {
            for (k, v) in $0 {
                _combineAttributes?[k] = v
            }
        }
        return _combineAttributes!
    }
}

extension Array: Stack {
    mutating func push(_ x: Element) { append(x) }
    @discardableResult
    mutating func pop() -> Element? { return popLast() }
    func peek() -> Element? { return last }
}

