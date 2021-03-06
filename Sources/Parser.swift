//
//  Parser.swift
//  MiniDOM
//
//  Copyright 2017 Anodized Software, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

/**
 Instances of this class parse XML documents into a tree of DOM objects.
 */
public class Parser {
    private let parser: XMLParser

    private let log = Log(level: .all)

    /**
     Used to represent a parser error.
     */
    public enum Error: Swift.Error {
        /**
         Indicates that the parser terminated abnormally resulting in the 
         associated error value
         */
        case parserError(Swift.Error)

        /**
         Indicates that the parser terminated abnormally but did not report an 
         error.
         */
        case unspecifiedError
    }


    /**
     Initializes a parser with the XML content referenced by the given URL.
     
     - parameter url: A `URL` object specifying a URL. The URL must be fully 
     qualified and refer to a scheme that is supported by the `URL` type.

     - returns: An initialized `Parser` object or `nil` if an error occurs.
     */
    public convenience init?(contentsOf url: URL) {
        self.init(parser: XMLParser(contentsOf: url))
    }

    /**
     Initializes a parser with the XML contents encapsulated in a given string 
     object.
     
     - parameter string: A `String` object containing XML markup.

     - parameter encoding: The encoding of the `String` object.

     - returns: An initialized `Parser` object or `nil` if an error occurs.
     */
    public convenience init?(string: String, encoding: String.Encoding = .utf8) {
        self.init(data: string.data(using: encoding))
    }

    /**
     Initializes a parser with the XML contents encapsulated in a given data 
     object.

     - parameter data: A `Data` object containing XML markup.

     - returns: An initialized `Parser` object.
     */
    public convenience init?(data: Data?) {
        guard let data = data else {
            return nil
        }

        self.init(parser: XMLParser(data: data))
    }

    /**
     Initializes a parser with the XML contents from the specified stream.
     
     - parameter stream: The input stream. The content is incrementally loaded 
     from the specified stream and parsed. The `Parser` will open the stream, 
     and synchronously read from it without scheduling it.

     - returns: An initialized `Parser` object.
     */
    public convenience init?(stream: InputStream) {
        self.init(parser: XMLParser(stream: stream))
    }

    init?(parser: XMLParser?) {
        guard let parser = parser else {
            return nil
        }

        self.parser = parser
    }

    public typealias ParserResult = Result<Document>

    /**
     Performs the parsing operation.
     
     - returns: The result of the parsing operation.
     */
    public final func parse() -> ParserResult {
        let stack = NodeStack()
        parser.delegate = stack

        guard parser.parse(), let document = stack.document else {
            let error = parser.parserError ?? Error.unspecifiedError
            log.error("Error parsing document: \(error)")
            return .failure(error)
        }

        parser.delegate = nil
        return .success(document)
    }
}

class NodeStack: NSObject, XMLParserDelegate {
    private let log = Log(level: .warn)

    private var stack: ArraySlice<Node> = []

    private func popAndAppendToTopOfStack(parser: XMLParser) {
        guard let child = stack.popLast() else {
            parser.abortParsing()
            return
        }

        appendToTopOfStack(child: child, parser: parser)
    }

    private func appendToTopOfStack(child: Node, parser: XMLParser) {
        guard var parent = stack.popLast() as? ParentNode else {
            parser.abortParsing()
            return
        }

        parent.append(child: child)
        stack.append(parent)
    }

    var document: Document? {
        return stack.first as? Document
    }

    func parserDidStartDocument(_ parser: XMLParser) {
        log.debug("")
        stack.append(Document())
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        log.debug("")
        // no-op; leave top of stack for caller
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        log.debug("elementName=\(elementName) attributes=\(attributeDict)")
        stack.append(Element(tagName: elementName, attributes: attributeDict))
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        log.debug("elementName=\(elementName)")
        popAndAppendToTopOfStack(parser: parser)
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let text = Text(text: string)
        appendToTopOfStack(child: text, parser: parser)
    }

    func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?) {
        log.debug("target=\(target) data=\(String(describing: data))")
        let pi = ProcessingInstruction(target: target, data: data)
        appendToTopOfStack(child: pi, parser: parser)
    }

    func parser(_ parser: XMLParser, foundComment comment: String) {
        log.debug("comment=\(comment)")
        let comment = Comment(text: comment)
        appendToTopOfStack(child: comment, parser: parser)
    }

    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        log.debug("CDATABlock=\(CDATABlock)")
        guard let text = String(data: CDATABlock, encoding: .utf8) else {
            log.error("invalid encoding")
            parser.abortParsing()
            return
        }
        
        let cdata = CDATASection(text: text)
        appendToTopOfStack(child: cdata, parser: parser)
    }
}
