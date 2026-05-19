import Foundation
import EventKit
import CoreResources

// MARK: - A domain-safe abstraction of a calendar.
public struct CalendarKit: Equatable, Sendable {
   public let id: String
   public let title: String
   public let source: String
   public let colorHex: String?
   
   public init(id: String,
               title: String,
               source: String,
               colorHex: String?) {
      self.id = id
      self.title = title
      self.source = source
      self.colorHex = colorHex
   }
}

// MARK: - Init from EKCalendar
public extension CalendarKit {
   init(calendar: EKCalendar) {
      self.id = calendar.calendarIdentifier
      self.title = calendar.title
      self.source = calendar.source.title
      self.colorHex = calendar.cgColor.hexString
   }
}
