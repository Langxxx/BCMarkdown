//
//  TextAttributes.swift
//  BCMarkdown
//
//  Created by wl on 15/08/2017.
//  Copyright © 2017 Beary Innovative. All rights reserved.
//

import UIKit

public typealias Attributes = [NSAttributedStringKey: Any]
public struct TextAttributes {
    public var textAttributes: Attributes
    
    public var h1Attributes: Attributes
    public var h2Attributes: Attributes
    public var h3Attributes: Attributes
    public var h4Attributes: Attributes
    public var h5Attributes: Attributes
    public var h6Attributes: Attributes

    public var thematicBreakAttributes: Attributes
    public var strongAttributes: Attributes
    public var linkAttributes: Attributes
    public var codeBlockAttributes: Attributes
    public var inlineCodeAttributes: Attributes
    public var blockQuoteAttributes: Attributes
    public var orderedListAttributes: Attributes
    public var unorderedListAttributes: Attributes
    public var orderedListItemAttributes: Attributes
    public var unorderedListItemAttributes: Attributes
    public var emphasisAttributes: Attributes
    public var paragraphAttributes: Attributes

    public var imagePlaceholderText = "image"
}

extension TextAttributes {
    public init() {
        let codeDefault: Attributes = {
            let size = UIFont.preferredFont(forTextStyle: .body).pointSize
            return [NSAttributedStringKey.font: UIFont(name: "Menlo", size: size) ?? UIFont.systemFont(ofSize: size)]
        }()
        let paragraphDefault: Attributes = {
            let style = NSMutableParagraphStyle()
            style.firstLineHeadIndent = 30
            style.headIndent = 30
            return [NSAttributedStringKey.paragraphStyle: style]
        }()
        let listParagraphDefault: Attributes = {
            let style = NSMutableParagraphStyle()
            style.paragraphSpacingBefore = 12
            return [NSAttributedStringKey.paragraphStyle: style]
        }()
        
        textAttributes = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: .body)]
        h1Attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 24)]
        h2Attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)]
        h3Attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)]
        h4Attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]
        h5Attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)]
        h6Attributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 8)]
        linkAttributes = [NSAttributedStringKey.foregroundColor: UIColor.blue]
        var blockCode = codeDefault
        blockCode[NSAttributedStringKey.paragraphStyle] = paragraphDefault[NSAttributedStringKey.paragraphStyle]
        thematicBreakAttributes = [:]
        codeBlockAttributes = blockCode
        inlineCodeAttributes = codeDefault
        blockQuoteAttributes = paragraphDefault
        orderedListAttributes = paragraphDefault
        unorderedListAttributes = paragraphDefault
        orderedListItemAttributes = [:]
        unorderedListItemAttributes = [:]
        strongAttributes = textAttributes
        emphasisAttributes = textAttributes
        paragraphAttributes = listParagraphDefault
    }
}

extension TextAttributes {
    func makeFontTraits(for attributeConfigure: Attributes, newTrait: UIFontDescriptorSymbolicTraits) -> Attributes {
        let baseFont = (attributeConfigure[NSAttributedStringKey.font] as? UIFont) ?? UIFont.systemFont(ofSize: 12)
        var traits = baseFont.fontDescriptor.symbolicTraits
        traits.insert(newTrait)
        guard let descriptor = baseFont.fontDescriptor.withSymbolicTraits(traits) else { return attributeConfigure }
        let newFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)
        var newAttrs = attributeConfigure
        newAttrs[NSAttributedStringKey.font] = newFont
        return newAttrs
    }
    
    func headerAttributes(for level: Int) -> Attributes {
        switch level {
        case 1: return h1Attributes
        case 2: return h2Attributes
        case 3: return h3Attributes
        case 4: return h4Attributes
        case 5: return h5Attributes
        default: return h6Attributes
        }
    }
    
    func listParagraphStyle(for type: ListType, at level: Int) -> Attributes {
        var attrs = type == .ordered ? orderedListAttributes : unorderedListAttributes
        guard let base = attrs[NSAttributedStringKey.paragraphStyle] as? NSParagraphStyle,
            let copy = base.mutableCopy() as? NSMutableParagraphStyle else {
                return attrs
        }
        
        copy.headIndent *= CGFloat(level)
        copy.firstLineHeadIndent *= CGFloat(level)
        attrs[NSAttributedStringKey.paragraphStyle] = copy
        return attrs
    }
}

