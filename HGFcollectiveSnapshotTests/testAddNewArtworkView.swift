//
//  testAddNewArtworkView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testAddNewArtworkView: XCTestCase {
    var addNewArtworkViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let addNewArtworkView = AddNewArtworkView()
        addNewArtworkViewController = UIHostingController(rootView: addNewArtworkView)
    }

    override func tearDown() {
        super.tearDown()
        addNewArtworkViewController = nil
    }

    func testAddNewArtworkViewLight() throws {
        assertSnapshot(
            matching: addNewArtworkViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testAddNewArtworkViewDark() throws {
        assertSnapshot(
            matching: addNewArtworkViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
