//
//  AttributedStringRenderer.swift
//  BCMarkdown
//
//  Created by wl on 15/08/2017.
//  Copyright © 2017 Beary Innovative. All rights reserved.
//

import UIKit

public class AttributedStringRenderer {
    let document: Document
    let textAttributes: TextAttributes
    
    fileprivate var _attributesConfigurator: AttributesConfigurator
    fileprivate var _listNumberStack: [Int] = []
    
    fileprivate var _attributedString: NSMutableAttributedString?
    
    public init(document: Document, textAttributesProvider: TextAttributes) {
        self.document = document
        self.textAttributes = textAttributesProvider
        _attributesConfigurator = AttributesConfigurator()
    }
}

extension AttributedStringRenderer {
    public func render() -> NSAttributedString {
        if let s = _attributedString { return s }
        _attributesConfigurator.empty()
        _attributesConfigurator.push(textAttributes.textAttributes)
        
        _attributedString = NSMutableAttributedString()
        _parse(with: document.rootNode.element)
        return _attributedString!.trailingNewlineChopped.headerNewlineChopped
    }
    
    private func _parse(with blocks: [Block]) {
        blocks.forEach { _parseBlock($0) }
    }
    
    private func _parseBlock(_ block: Block) {
        defer {
            _attributesConfigurator.pop()
            switch block {
            case .items: ()
            default: append(with: NSAttributedString(string: "\n"))
            }
            
        }
        switch block {
        case .codeBlock(let text, _):
            _attributesConfigurator.push(textAttributes.codeBlockAttributes)
            append(with: text)
        case .custom(let literal):
            _attributesConfigurator.push(textAttributes.textAttributes)
            append(with: literal)
        case .html(let text):
            _attributesConfigurator.push([:])
            append(with: text) // TODO: Support html
        case .thematicBreak:
            _attributesConfigurator.push([:])
            append(with: "") // TODO:
        case .blockQuote(let items):
            _attributesConfigurator.push(textAttributes.blockQuoteAttributes)
            _parse(with: items)
        case .heading(let inlines, let level):
            _attributesConfigurator.push(textAttributes.headerAttributes(for: level))
            _parse(with: inlines)
        case .paragraph(let inlines, let isTightList):
            _attributesConfigurator.push([:])
            if isTightList { append(with: NSAttributedString(string: "\n")) }
            _parse(with: inlines)
        case .list(let items, let type, let start, let level):
            _attributesConfigurator.push(textAttributes.listParagraphStyle(for: type, at: level))
            _listNumberStack.push(start)
            append(with: NSAttributedString(string: "\n"))
            _parse(with: items)
            _listNumberStack.pop()
        case .items(let items, let type, let delim):
            let currentIndex = _listNumberStack.pop() ?? 0
            _listNumberStack.push(currentIndex + 1)
            let headerStr = type == .ordered ? "\(currentIndex)" + delim + " " : "• "
            let attr = type == .ordered ? textAttributes.orderedListItemAttributes : textAttributes.unorderedListItemAttributes
            _attributesConfigurator.push(attr)
            append(with: headerStr)
            _parse(with: items)
            
        }
    }
    
    private func _parse(with inlines: [Inline]) {
        inlines.forEach { _parseInline($0) }
    }
    
    private func _parseInline(_ inline: Inline) {
        defer { _attributesConfigurator.pop() }
        switch inline {
        case .text(let text):
            _attributesConfigurator.push([:])
            append(with: text)
        case .code(let text):
            _attributesConfigurator.push(textAttributes.inlineCodeAttributes)
            append(with: text)
        case .custom(let literal):
            _attributesConfigurator.push([:])
            append(with: literal) // TODO:
        case .emphasis(let children):
            let emphasisAttr = textAttributes.makeFontTraits(for: textAttributes.emphasisAttributes, newTrait: .traitItalic)
            _attributesConfigurator.push(emphasisAttr)
            _parse(with: children)
        case .html(let text): // TODO:
            _attributesConfigurator.push([:])
            append(with: text)
        case .image(_, _, let url):
            var linkAttrs = textAttributes.linkAttributes
            linkAttrs[NSAttributedStringKey.link] = url
            _attributesConfigurator.push(linkAttrs)
            append(with: textAttributes.imagePlaceholderText)
        case .lineBreak:
            _attributesConfigurator.push([:])
            append(with: "\n")
        case .link(let children, _, let url):
            var linkAttrs = textAttributes.linkAttributes
            linkAttrs[NSAttributedStringKey.link] = url
            _attributesConfigurator.push(linkAttrs)
            _parse(with: children)
        case .softBreak:
            _attributesConfigurator.push([:])
            if document.option.contains(.hardBreaks) {
                append(with: NSAttributedString(string: "\n"))
            } else {
                append(with: " ")
            }
        case .strong(let children):
            let strongAttr = textAttributes.makeFontTraits(for: textAttributes.strongAttributes, newTrait: .traitBold)
            _attributesConfigurator.push(strongAttr)
            _parse(with: children)
        }
    }
}

extension AttributedStringRenderer {
    func append(with string: String) {
        _attributedString?.append(.init(string: string, attributes: _attributesConfigurator.combineAttributes()))
    }
    func append(with attrStr: NSAttributedString) {
        _attributedString?.append(attrStr)
    }
}

fileprivate extension NSMutableAttributedString {
    var trailingNewlineChopped: NSMutableAttributedString {
        if length <= 0 { return self }
        let lastCharRange = NSRange(location: length - 1, length: 1)
        let lastChar = self.attributedSubstring(from: lastCharRange).string
        if lastChar == "\n" {
            deleteCharacters(in: lastCharRange)
        }
        return self
    }
    
    var headerNewlineChopped: NSMutableAttributedString {
        if length <= 0 { return self }
        let firstCharRange = NSRange(location: 0, length: 1)
        let firstChar = self.attributedSubstring(from: firstCharRange).string
        if firstChar == "\n" {
            deleteCharacters(in: firstCharRange)
        }
        return self
    }
}

