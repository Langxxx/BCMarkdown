//
//  Node.swift
//  BCMarkdown
//
//  Created by wl on 15/08/2017.
//  Copyright © 2017 Beary Innovative. All rights reserved.
//

import Foundation
import cmark

public class Node {
    let node: OpaquePointer
    private let _freeWhenDone: Bool
    init(node: OpaquePointer, freeWhenDone: Bool = true) {
        self.node = node
        _freeWhenDone = freeWhenDone
    }

    init?(markdown: String) {
        let parsed = cmark_parse_document(markdown, markdown.utf8.count, 0)
        guard let node = parsed else { return nil}
        self.node = node
        _freeWhenDone = true
    }

    deinit {
        guard type == CMARK_NODE_DOCUMENT, _freeWhenDone else { return }
        cmark_node_free(node)
    }
}

extension String {
    init?(unsafeCString: UnsafePointer<Int8>!) {
        guard let cString = unsafeCString else { return nil }
        self.init(cString: cString)
    }
}

extension Node {
    convenience init(type: cmark_node_type, literal: String) {
        self.init(type: type)
        self.literal = literal
    }
    convenience init(type: cmark_node_type, children: [Node] = []) {
        self.init(node: cmark_node_new(type))
        for child in children {
            cmark_node_append_child(node, child.node)
        }
    }
    convenience init(type: cmark_node_type, blocks: [Block]) {
        self.init(type: type, children: blocks.map(Node.init))
    }
    convenience init(type: cmark_node_type, elements: [Inline]) {
        self.init(type: type, children: elements.map(Node.init))
    }
    convenience init(blocks: [Block]) {
        self.init(type: CMARK_NODE_DOCUMENT, blocks: blocks)
    }
}

extension Node {
    convenience init(element: Inline) {
        switch element {
        case .text(let text):
            self.init(type: CMARK_NODE_TEXT, literal: text)
        case .emphasis(let children):
            self.init(type: CMARK_NODE_EMPH, elements: children)
        case .code(let text):
            self.init(type: CMARK_NODE_CODE, literal: text)
        case .strong(let children):
            self.init(type: CMARK_NODE_STRONG, elements: children)
        case .html(let text):
            self.init(type: CMARK_NODE_HTML_INLINE, literal: text)
        case .custom(let literal):
            self.init(type: CMARK_NODE_CUSTOM_INLINE, literal: literal)
        case let .link(children, title, url):
            self.init(type: CMARK_NODE_LINK, elements: children)
            self.title = title
            self.urlString = url
        case let .image(children, title, url):
            self.init(type: CMARK_NODE_IMAGE, elements: children)
            self.title = title
            urlString = url
        case .softBreak:
            self.init(type: CMARK_NODE_SOFTBREAK)
        case .lineBreak:
            self.init(type: CMARK_NODE_LINEBREAK)
        }
    }
    convenience init(block: Block) {
        switch block {
        case .paragraph(let children, _): // TODO keep list tight
            self.init(type: CMARK_NODE_PARAGRAPH, elements: children)
        case let .list(items, type, _, _): // TODO: keep list level
            self.init(type: CMARK_NODE_LIST, blocks: items)
            listType = type == .unordered ? CMARK_BULLET_LIST : CMARK_ORDERED_LIST
        case .items(let items, _, _): // TODO: keep start idnex
            self.init(type: CMARK_NODE_ITEM, blocks: items)
        case .blockQuote(let items):
            self.init(type: CMARK_NODE_BLOCK_QUOTE, blocks: items)
        case let .codeBlock(text, language):
            self.init(type: CMARK_NODE_CODE_BLOCK, literal: text)
            fenceInfo = language
        case .html(let text):
            self.init(type: CMARK_NODE_HTML_BLOCK, literal: text)
        case .custom(let literal):
            self.init(type: CMARK_NODE_CUSTOM_BLOCK, literal: literal)
        case let .heading(text, level):
            self.init(type: CMARK_NODE_HEADING, elements: text)
            headerLevel = level
        case .thematicBreak:
            self.init(type: CMARK_NODE_THEMATIC_BREAK)
        }
    }
}

extension Node {
    var type: cmark_node_type {
        return cmark_node_get_type(node)
    }

    var listType: cmark_list_type {
        get { return cmark_node_get_list_type(node) }
        set { cmark_node_set_list_type(node, newValue) }
    }

    var children: AnySequence<Node> {
        return AnySequence { () -> AnyIterator<Node> in
            var child = cmark_node_first_child(self.node)
            return AnyIterator {
                let result: Node? = child == nil ? nil : Node(node: child!)
                child = cmark_node_next(child)
                return result
            }
        }
    }

    var literal: String? {
        get { return String(unsafeCString: cmark_node_get_literal(node)) }
        set { cmark_node_set_literal(node, newValue) }
    }

    var title: String? {
        get { return String(unsafeCString: cmark_node_get_title(node) )}
        set { cmark_node_set_title(node, newValue) }
    }

    var urlString: String? {
        get { return String(unsafeCString: cmark_node_get_url(node)) }
        set { cmark_node_set_url(node, newValue) }
    }

    var fenceInfo: String? {
        get { return String(unsafeCString: cmark_node_get_fence_info(node)) }
        set { cmark_node_set_fence_info(node, newValue) }
    }

    var headerLevel: Int {
        get { return Int(cmark_node_get_heading_level(node)) }
        set { cmark_node_set_heading_level(node, Int32(newValue)) }
    }

    var typeString: String {
        return String(cString: cmark_node_get_type_string(node)!)
    }

    var isTightList: Bool {
        return cmark_node_get_list_tight(node) == 1
    }

    var listStart: Int {
        return Int(cmark_node_get_list_start(node))
    }

    var listDelim: cmark_delim_type {
        return cmark_node_get_list_delim(node)
    }

    var parent: Node? {
        guard let parent = cmark_node_parent(node) else { return nil }
        return Node(node: parent, freeWhenDone: false)
    }
}

