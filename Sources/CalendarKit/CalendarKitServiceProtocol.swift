import Foundation

// Public-facing protocol for calendar service behavior.
public protocol CalendarKitServiceProtocol: Sendable {
   func requestAccess() async throws
   
   func fetchCalendars() async throws -> [CalendarKit]
   
   func getCalendar(calendarID: String) async throws -> CalendarKit?
   
   func fetchEvents(calendarID: String?,
                    from startDate: Date,
                    to endDate: Date) async throws -> [CalendarKitEvent]
   
   func addEvent(event: CalendarKitEvent,
                 to calendar: CalendarKit) async throws
   
   func updateEvent(event: CalendarKitEvent,
                    of calendar: CalendarKit) async throws
   
   func deleteEvent(with eventID: String) async throws
}

public extension CalendarKitServiceProtocol {
   func fetchEvents(from startDate: Date,
                    to endDate: Date) async throws -> [CalendarKitEvent] {
      try await fetchEvents(calendarID: nil,
                            from: startDate,
                            to: endDate)
   }
}
