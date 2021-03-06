//
//  LogTests.swift
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
import XCTest

@testable import MiniDOM

class LogTests: XCTestCase {
    func check(log: Log, expectError: Bool, expectWarn: Bool, expectInfo: Bool, expectDebug: Bool, expectVerbose: Bool, file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(log.error("Error"), expectError, file: file, line: line)
        XCTAssertEqual(log.error(NSError.init(domain: "anErrorDomain", code: 123456, userInfo: nil)), expectError, file: file, line: line)
        XCTAssertEqual(log.warn("Warn"), expectWarn, file: file, line: line)
        XCTAssertEqual(log.info("Info"),  expectInfo, file: file, line: line)
        XCTAssertEqual(log.debug("Debug"), expectDebug, file: file, line: line)
        XCTAssertEqual(log.verbose("Verbose"), expectVerbose, file: file, line: line)
    }

    func testLogLevels() {
        check(log: Log(level: .all),     expectError: true,  expectWarn: true,  expectInfo: true,  expectDebug: true,  expectVerbose: true)
        check(log: Log(level: .verbose), expectError: true,  expectWarn: true,  expectInfo: true,  expectDebug: true,  expectVerbose: true)
        check(log: Log(level: .debug),   expectError: true,  expectWarn: true,  expectInfo: true,  expectDebug: true,  expectVerbose: false)
        check(log: Log(level: .info),    expectError: true,  expectWarn: true,  expectInfo: true,  expectDebug: false, expectVerbose: false)
        check(log: Log(level: .warn),    expectError: true,  expectWarn: true,  expectInfo: false, expectDebug: false, expectVerbose: false)
        check(log: Log(level: .error),   expectError: true,  expectWarn: false, expectInfo: false, expectDebug: false, expectVerbose: false)
        check(log: Log(level: .off),     expectError: false, expectWarn: false, expectInfo: false, expectDebug: false, expectVerbose: false)
    }
}
