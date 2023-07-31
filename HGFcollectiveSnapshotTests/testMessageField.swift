//
//  testMessageField.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testMessageField: XCTestCase {
    var messageFieldController: UIViewController!

    override func setUp() {
        super.setUp()
        let messageField = MessageField()
        messageFieldController = UIHostingController(rootView: messageField)
    }

    override func tearDown() {
        super.tearDown()
        messageFieldController = nil
    }

    func testMessageFieldLight() throws {
        assertSnapshot(
            matching: messageFieldController,
            as: .image(on: .iPhoneX)
        )
    }

    func testMessageFieldDark() throws {
        assertSnapshot(
            matching: messageFieldController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
