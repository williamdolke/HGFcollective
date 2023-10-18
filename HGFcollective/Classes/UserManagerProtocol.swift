//
//  UserManagerProtocol.swift
//  HGFcollective
//
//  Created by William Dolke on 03/10/2023.
//

import Foundation

protocol UserManagerProtocol {
    var users: [User] { get set }
    var messagesManagers: [String: MessagesManager] { get set }
    var unreadMessages: Int { get set }

    func login()
    func logout()

    func countUnreadMessages()
    func storePreferredName(name: String, id: String)
}
