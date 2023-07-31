//
//  testSubmitButton.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testSubmitButton: XCTestCase {
    var submitButtonController: UIViewController!

    override func setUp() {
        super.setUp()
        let submitButton = SubmitButton(action: {})
        submitButtonController = UIHostingController(rootView: submitButton)
    }

    override func tearDown() {
        super.tearDown()
        submitButtonController = nil
    }

    func testSubmitButtonLight() throws {
        assertSnapshot(
            matching: submitButtonController,
            as: .image(on: .iPhoneX)
        )
    }

    func testSubmitButtonDark() throws {
        assertSnapshot(
            matching: submitButtonController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
