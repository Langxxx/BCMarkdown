//
//  Document.swift
//  BCMarkdown
//
//  Created by wl on 15/08/2017.
//  Copyright © 2017 Beary Innovative. All rights reserved.
//

import Foundation

public struct Document {
    public let rootNode: Node
    let option: DocumentOptions
}

public extension Document {
    init?(string: String, option: DocumentOptions = []) {
        guard let node = Node(markdown: string) else { return nil }
        rootNode = node
        self.option = option
    }
}

public struct DocumentOptions: OptionSet {
    public let rawValue: Int

    public static let sourcepos = DocumentOptions(rawValue: (1 << 0))
    public static let hardBreaks = DocumentOptions(rawValue: (1 << 1))
    public static let normalize = DocumentOptions(rawValue: (1 << 3))
    public static let smart = DocumentOptions(rawValue: (1 << 3))

    public init(rawValue: Int) { self.rawValue = rawValue }
}

