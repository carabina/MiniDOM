//
//  ParserErrorTests.swift
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
import Nimble
import XCTest

@testable import MiniDOM

class ParserErrorTests: XCTestCase {
    func testInvalidProcessingInstruction() {
        let source = [
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<? target data ?>",
            "<foo>",
            "  <bar/>",
            "</foo>"
        ].joined(separator: "\n")

        let parser = Parser(string: source)
        expect(parser).notTo(beNil())

        let result = parser?.parse()
        expect(result).notTo(beNil())
        expect(result?.value).to(beNil())
        expect(result?.error).notTo(beNil())

        expect(result?.error).to(matchError(NSError(domain: XMLParser.errorDomain, code: 111, userInfo: nil)))
    }

    func testExtraCloseTags() {
        let source = [
            "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
            "<foo>",
            "  <bar></bar></bar>",
            "</foo>"
            ].joined(separator: "\n")

        let parser = Parser(string: source)
        expect(parser).notTo(beNil())

        let result = parser?.parse()
        expect(result).notTo(beNil())
        expect(result?.value).to(beNil())
        expect(result?.error).notTo(beNil())

        expect(result?.error).to(matchError(NSError(domain: XMLParser.errorDomain, code: 111, userInfo: nil)))
    }

    func testSuccessResult() {
        let document = Document()
        let result = Result.success(document)
        expect(result.isSuccess).to(beTrue())
        expect(result.isFailure).to(beFalse())
        expect(result.value) === document
        expect(result.error).to(beNil())
    }

    func testFailureResult() {
        let error = NSError(domain: "domain", code: 123, userInfo: nil)
        let result = Result<Document>.failure(error)
        expect(result.isSuccess).to(beFalse())
        expect(result.isFailure).to(beTrue())
        expect(result.value).to(beNil())
        expect(result.error) === error
    }

    func testInvalidCDATABlock() {
        class TestXMLParser: XMLParser {
            var parsingAborted = false

            override func abortParsing() {
                parsingAborted = true
            }
        }

        let bytes: [UInt8] = [192]
        let invalidUTF8data = Data(bytes: bytes)

        let nodeStack = NodeStack()
        let parser = TestXMLParser()

        nodeStack.parser(parser, foundCDATA: invalidUTF8data)
        expect(parser.parsingAborted).to(beTrue())
    }

    func testNilDocumentNoError() {
        class TestXMLParser: XMLParser {
            override func parse() -> Bool {
                return false
            }

            override var parserError: Error? {
                return nil
            }
        }

        let parser = Parser(parser: TestXMLParser())
        expect(parser).notTo(beNil())

        let result = parser?.parse()
        expect(result).notTo(beNil())

        expect(result?.error).to(matchError(Parser.Error.unspecifiedError))
        expect(result?.value).to(beNil())
    }
}
