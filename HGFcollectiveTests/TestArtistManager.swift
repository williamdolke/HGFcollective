//
//  TestArtistManager.swift
//  HGFcollectiveTests
//
//  Created by William Dolke on 11/12/2022.
//

import XCTest
import SwiftUI
@testable import HGFcollective

final class TestArtistManager: XCTestCase {
    var artistManager: ArtistManager!

    override func setUp() {
        super.setUp()
        artistManager = ArtistManager.shared
    }

    override func tearDown() {
        super.tearDown()
        artistManager = nil
    }

    func testGetUniqueRandomNumbers() throws {
        let uniqueRandomNumbers = artistManager.getUniqueRandomNumbers(min: 0,
                                                                       max: 10,
                                                                       count: artistManager.numDiscoverArtists)

        XCTAssertEqual(artistManager.numDiscoverArtists, uniqueRandomNumbers.count)
        // Check there are no duplicate elements (Set() will remove any duplicates)
        XCTAssertEqual(uniqueRandomNumbers.count, Array(Set(uniqueRandomNumbers)).count)
    }

    func testGetArtworkInfoComplete() throws {
        let artwork = Artwork(name: "Artwork",
                              editionNumber: "5",
                              editionSize: "100",
                              material: "Oil paints on canvas",
                              dimensionUnframed: "60cm x 80cm",
                              dimensionFramed: "65cm x 85cm",
                              year: "2020",
                              signed: "Yes",
                              numbered: "No",
                              stamped: "Yes",
                              authenticity: "With piece")
        let info = artistManager.getArtworkInfo(artwork: artwork)
        let expectedString = """
                             **Edition Number:** 5
                             **Edition Size:** 100
                             **Materials:** Oil paints on canvas
                             **Dimensions Unframed:** 60cm x 80cm
                             **Dimensions Framed:** 65cm x 85cm
                             **Year of release:** 2020
                             **Signed:** Yes
                             **Numbered:** No
                             **Stamped:** Yes
                             **Certificate of authenticity:** With piece
                             """
        let expectedText = Text(try AttributedString(markdown: expectedString,
                                            options: AttributedString.MarkdownParsingOptions(interpretedSyntax:
                                                    .inlineOnlyPreservingWhitespace)))

        XCTAssertEqual(info, expectedText)
    }

    func testGetArtworkInfoSparse() throws {
        let artwork = Artwork(name: "Artwork",
                              editionNumber: "5",
                              material: "Oil paints on canvas",
                              dimensionFramed: "65cm x 85cm",
                              signed: "Yes",
                              stamped: "Yes")
        let info = artistManager.getArtworkInfo(artwork: artwork)
        let expectedString = """
                             **Edition Number:** 5
                             **Materials:** Oil paints on canvas
                             **Dimensions Framed:** 65cm x 85cm
                             **Signed:** Yes
                             **Stamped:** Yes
                             """
        let expectedText = Text(try AttributedString(markdown: expectedString,
                                            options: AttributedString.MarkdownParsingOptions(interpretedSyntax:
                                                    .inlineOnlyPreservingWhitespace)))

        XCTAssertEqual(info, expectedText)
    }

    func testGetArtworkInfoEmpty() throws {
        let artwork = Artwork(name: "Artwork")
        let info = artistManager.getArtworkInfo(artwork: artwork)

        XCTAssertNil(info)
    }
}
