//
//  TestImageUtils.swift
//  HGFcollectiveTests
//
//  Created by William Dolke on 29/12/2023.
//

import XCTest
@testable import HGFcollective

final class TestImageUtils: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testGetImagesWithNoUrls() throws {
        let imageTuple = ImageUtils.getImages(artworkName: "test", artworkURLs: nil)
        XCTAssertEqual(imageTuple.images, [])
        XCTAssertEqual(imageTuple.numAssets, nil)
    }
}
