import Foundation
import EventKit

// MARK: - Represents a calendar event.
public struct CalendarKitEvent: Equatable, Sendable {
   public let calendar: CalendarKit
   public let id: String
   public let title: String
   public let startDate: Date
   public let endDate: Date
   public let location: String?
   public let notes: String?
   
   public init(calendar: CalendarKit,
               id: String,
               title: String,
               startDate: Date,
               endDate: Date,
               location: String?,
               notes: String?) {
      self.calendar = calendar
      self.id = id
      self.title = title
      self.startDate = startDate
      self.endDate = endDate
      self.location = location
      self.notes = notes
   }
}

// MARK: - Init from EKEvent
public extension CalendarKitEvent {
   init(event: EKEvent) {
      self.calendar = CalendarKit(calendar: event.calendar)
      self.id = event.eventIdentifier
      self.title = event.title
      self.startDate = event.startDate
      self.endDate = event.endDate
      self.location = event.location
      self.notes = event.notes
   }
}
