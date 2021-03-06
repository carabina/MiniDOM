//
//  StringWhitespaceTests.swift
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
import MiniDOM
import XCTest

class StringWhitespaceTests: XCTestCase {
    func testTrimFromBeginning() {
        XCTAssertEqual("\n\t   foo".trimmed, "foo")
    }

    func testTrimFromEnd() {
        XCTAssertEqual("foo   \n\t".trimmed, "foo")
    }

    func testTrimFromBeginningAndEnd() {
        XCTAssertEqual("\n\t   foo   \n\t".trimmed, "foo")
    }

    func testCollapse() {
        XCTAssertEqual(" foo   \n\t  bar ".collapsed, " foo bar ")
    }

    func testNormalize() {
        XCTAssertEqual("  foo  \r\n\t bar   ".normalized, "foo bar")
    }

    func testNormalizeNewlineVariants() {
        XCTAssertEqual("foo\rbar".normalized, "foo bar")
        XCTAssertEqual("foo\nbar".normalized, "foo bar")
        XCTAssertEqual("foo\r\nbar".normalized, "foo bar")

        XCTAssertEqual("foo \rbar".normalized, "foo bar")
        XCTAssertEqual("foo \nbar".normalized, "foo bar")
        XCTAssertEqual("foo \r\nbar".normalized, "foo bar")
    }
}
