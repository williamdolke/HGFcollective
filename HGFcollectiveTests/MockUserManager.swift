//
//  MockUserManager.swift
//  HGFcollectiveTests
//
//  Created by William Dolke on 31/07/2023.
//

import Foundation
@testable import HGFcollective

class MockUserManager: UserManager {
    override func login() {
        let user = User(id: "testID",
                         messagePreview: "Test message.",
                         latestTimestamp: Date.now,
                         read: false, sender: "test",
                         isCustomer: true)
        self.users = [user]
        self.unreadMessages = 1
        return
    }
}
