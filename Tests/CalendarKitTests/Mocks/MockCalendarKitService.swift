import Foundation
import CoreResources
@testable import CalendarKit

actor MockCalendarService: CalendarKitServiceProtocol {
   private(set) var calendars: [CalendarKit]
   private(set) var events: [CalendarKitEvent]
   private(set) var shouldThrow: Bool = false
   
   init(calendars: [CalendarKit],
        events: [CalendarKitEvent]) {
      self.calendars = calendars
      self.events = events
   }
   
   // MARK: - Protocol
   func requestAccess() async throws {
      if shouldThrow { throw CalendarKitError.accessDenied }
   }
   
   func fetchCalendars() async throws -> [CalendarKit] {
      calendars
   }
   
   func getCalendar(calendarID: String) async throws -> CalendarKit? {
      calendars.first(where: \.id == calendarID)
   }
   
   func fetchEvents(calendarID: String?,
                    from startDate: Date,
                    to endDate: Date) async throws -> [CalendarKitEvent] {
      if let calendarID {
         return events.filter { $0.calendar.id == calendarID && $0.startDate >= startDate && $0.endDate <= endDate }
      }
      
      return events.filter { $0.startDate >= startDate && $0.endDate <= endDate }
   }
   
   func addEvent(event: CalendarKitEvent, to calendar: CalendarKit) async throws {
      events.append(event)
   }
   
   func updateEvent(event: CalendarKitEvent, of calendar: CalendarKit) async throws {
      guard let index = events.firstIndex(where: { $0.id == event.id }) else {
         throw CalendarKitError.eventNotFound
      }
      
      events[index] = event
   }
   
   func deleteEvent(with eventID: String) async throws {
      guard let index = events.firstIndex(where: \.id == eventID) else {
         throw CalendarKitError.eventNotFound
      }
      events.remove(at: index)
   }
   
   // MARK: - Helper method
   func setShouldThrow(_ value: Bool) async throws {
      self.shouldThrow = value
   }
}
