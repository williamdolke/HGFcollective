//
//  TestUserManager.swift
//  HGFcollectiveTests
//
//  Created by William Dolke on 03/10/2023.
//

import XCTest
@testable import HGFcollective

final class TestUserManager: XCTestCase {
    var userManager: UserManagerProtocol!

    override func setUp() {
        super.setUp()
        userManager = MockUserManager()
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testLogin() {
        userManager.login()
        XCTAssertEqual(userManager.users.count, 1)
        XCTAssertEqual(userManager.unreadMessages, 1)
    }

    func testLogout() {
        userManager.logout()
        XCTAssertEqual(userManager.users.count, 0)
        XCTAssertEqual(userManager.messagesManagers.count, 0)
        XCTAssertEqual(userManager.unreadMessages, 0)
    }
}
