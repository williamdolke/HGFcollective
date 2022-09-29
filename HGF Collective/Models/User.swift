//
//  User.swift
//  HGF Collective
//
//  Created by William Dolke on 26/09/2022.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var messagePreview: String
    var latestTimestamp: Date
    @NotCoded var messagesManager: MessagesManager?
}

/// A property wrapper for properties of a type that
/// should be "skipped" when the type is encoded or decoded.
@propertyWrapper
public struct NotCoded<Value> {
  private var value: Value?
  public init(wrappedValue: Value?) {
    self.value = wrappedValue
  }
  public var wrappedValue: Value? {
    get { value }
    set { self.value = newValue }
  }
}

extension NotCoded: Codable {
  public func encode(to encoder: Encoder) throws {
    // Skip encoding the wrapped value.
  }
  public init(from decoder: Decoder) throws {
    // The wrapped value is simply initialised to nil when decoded.
    self.value = nil
  }
}
