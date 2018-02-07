公告啊啊啊啊啊 @langxxx  :smiley:  :smile: 

## CocoaMarkdown
#### Markdown parsing and rendering for iOS and OS X

CocoaMarkdown is a cross-platform framework for parsing and rendering Markdown, built on top of the [C reference implementation](https://github.com/jgm/CommonMark) of [CommonMark](http://commonmark.org).

**This is currently beta-quality code.**

### Why?

CocoaMarkdown aims to solve two primary problems better than existing libraries:C

1. **More flexibility**. CocoaMarkdown allows you to define custom parsing hooks or even traverse the Markdown AST using the low-level API.
2. **Efficient `NSAttributedString` creation for easy rendering on iOS and OS X**. Most existing libraries just generate HTML from the Markdown, which is not a convenient representation to work with in native apps.

### In

#### Building Custom Renderers

The [`CMParser`](https://github.com/indragiek/CocoaMarkdown/blob/master/CocoaMarkdown/CMParser.h) class isn't _really_ a parser (it just traverses the AST), but it defines an `NSXMLParser`-style delegate API that provides handy callbacks for building your own renderers:

