//
//  testUserManager.swift
//  HGFcollectiveTests
//
//  Created by William Dolke on 11/12/2022.
//

import XCTest
@testable import HGFcollective

final class testUserManager: XCTestCase {
    
    var userManager: UserManager!

    override func setUp() {
        super.setUp()
        userManager = nil
    }

    override func tearDown(){
        super.tearDown()
        userManager = nil
    }

    func testSortUsers() throws {
        userManager.sortUsers()
        
        
    }
}
