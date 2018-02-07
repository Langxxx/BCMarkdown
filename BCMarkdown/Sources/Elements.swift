//
//  Elements.swift
//  BCMarkdown
//
//  Created by wl on 15/08/2017.
//  Copyright © 2017 Beary Innovative. All rights reserved.
//

import Foundation

enum Inline {
    case text(text: String)
    case softBreak
    case lineBreak
    case code(text: String)
    case html(text: String)
    case emphasis(children: [Inline])
    case strong(children: [Inline])
    case custom(literal: String)
    case link(children: [Inline], title: String?, url: String?)
    case image(children: [Inline], title: String?, url: String?)
}

extension Inline {
    init(_ node: Node) {
        let inlineChildren = { node.children.map(Inline.init) }

        switch node.type {
        case CMARK_NODE_TEXT:
            self = .text(text: node.literal!)
        case CMARK_NODE_SOFTBREAK:
            self = .softBreak
        case CMARK_NODE_LINEBREAK:
            self = .lineBreak
        case CMARK_NODE_CODE:
            self = .code(text: node.literal!)
        case CMARK_NODE_HTML_INLINE:
            self = .html(text: node.literal!)
        case CMARK_NODE_CUSTOM_INLINE:
            self = .custom(literal: node.literal!)
        case CMARK_NODE_EMPH:
            self = .emphasis(children: inlineChildren())
        case CMARK_NODE_STRONG:
            self = .strong(children: inlineChildren())
        case CMARK_NODE_LINK:
            self = .link(children: inlineChildren(), title: node.title, url: node.urlString)
        case CMARK_NODE_IMAGE:
            self = .image(children: inlineChildren(), title: node.title, url: node.urlString)
        default:
            fatalError("Unrecognized node: \(node.typeString)")
        }
    }
}

enum ListType {
    case unordered
    case ordered
}
enum ListDelim: String {
    case period = "."
    case paren = ")"
}

enum Block {
    case list(items: [Block], type: ListType, start: Int, level: Int)
    case items(items: [Block], type: ListType, delim: String)
    case blockQuote(items: [Block])
    case codeBlock(text: String, language: String?)
    case html(text: String)
    case paragraph(text: [Inline], isTightList: Bool)
    case heading(text: [Inline], level: Int)
    case custom(literal: String)
    case thematicBreak
}


extension Block {
    init(_ node: Node) {
        let parseInlineChildren = { node.children.map(Inline.init) }
        let parseBlockChildren = { node.children.map(Block.init) }
        switch node.type {
        case CMARK_NODE_PARAGRAPH:
            self = .paragraph(text: parseInlineChildren(), isTightList: node.isTightList)
        case CMARK_NODE_BLOCK_QUOTE:
            self = .blockQuote(items: parseBlockChildren())
        case CMARK_NODE_LIST:
            let type: ListType = node.listType == CMARK_BULLET_LIST ?
                .unordered : .ordered
            let items = node.listItem
            let level = node.listLevel
            self = .list(items: items, type: type, start: node.listStart, level: level)
        case CMARK_NODE_ITEM:
            let type: ListType = node.parent!.listType == CMARK_BULLET_LIST ?
                .unordered : .ordered
            let delim: ListDelim = node.parent!.listDelim == CMARK_PERIOD_DELIM ? .period : .paren
            self = .items(items: parseBlockChildren(), type: type, delim: delim.rawValue)
        case CMARK_NODE_CODE_BLOCK:
            self = .codeBlock(text: node.literal!, language: node.fenceInfo)
        case CMARK_NODE_HTML_BLOCK:
            self = .html(text: node.literal!)
        case CMARK_NODE_CUSTOM_BLOCK:
            self = .custom(literal: node.literal!)
        case CMARK_NODE_HEADING:
            self = .heading(text: parseInlineChildren(), level: node.headerLevel)
        case CMARK_NODE_THEMATIC_BREAK:
            self = .thematicBreak
        default:
            fatalError("Unrecognized node: \(node.typeString)")
        }
    }
}

extension Node {
    var listItem: [Block] {
        return children.map(Block.init)
    }

    var element: [Block] {
        return children.map(Block.init)
    }

    var listLevel: Int {
        guard let parent = parent else { return 0 }
        return parent.listLevel + (listType == CMARK_NO_LIST ? 0 : 1)
    }
}

