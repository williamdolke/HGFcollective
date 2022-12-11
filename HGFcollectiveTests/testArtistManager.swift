//
//  testArtistManager.swift
//  HGFcollectiveTests
//
//  Created by William Dolke on 11/12/2022.
//

import XCTest
@testable import HGFcollective

final class testArtistManager: XCTestCase {
    
    var artistManager: ArtistManager!
    
    override func setUp() {
        super.setUp()
        artistManager = ArtistManager()
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
}
