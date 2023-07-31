//
//  testAddNewArtistView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testAddNewArtistView: XCTestCase {
    var addNewArtistViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let addNewArtistView = AddNewArtistView()
        addNewArtistViewController = UIHostingController(rootView: addNewArtistView)
    }

    override func tearDown() {
        super.tearDown()
        addNewArtistViewController = nil
    }

    func testAddNewArtistViewLight() throws {
        assertSnapshot(
            matching: addNewArtistViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testAddNewArtistViewDark() throws {
        assertSnapshot(
            matching: addNewArtistViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
