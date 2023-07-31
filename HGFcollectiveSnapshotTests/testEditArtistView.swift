//
//  testEditArtistView.swift
//  HGFcollectiveSnapshotTests
//
//  Created by William Dolke on 30/07/2023.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import HGFcollective

final class testEditArtistView: XCTestCase {
    var editArtistViewController: UIViewController!

    override func setUp() {
        super.setUp()
        let editArtistView = EditArtistView()
            .environmentObject(ArtistManager())
        editArtistViewController = UIHostingController(rootView: editArtistView)
    }

    override func tearDown() {
        super.tearDown()
        editArtistViewController = nil
    }

    func testEditArtistViewLight() throws {
        assertSnapshot(
            matching: editArtistViewController,
            as: .image(on: .iPhoneX)
        )
    }

    func testEditArtistViewDark() throws {
        assertSnapshot(
            matching: editArtistViewController,
            as: .image(on: .iPhoneX, traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }
}
