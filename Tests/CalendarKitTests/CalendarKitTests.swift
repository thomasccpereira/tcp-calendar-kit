import Foundation
import Testing
@testable import CalendarKit

@Suite
struct CalendarServiceTests {
   private let service: MockCalendarService
   private let calendar: CalendarKit
   private let now = Date()
   
   init() {
      self.calendar = CalendarKit(id: "1",
                                  title: "Personal",
                                  source: "iCloud",
                                  colorHex: "#DDDDDD")
      
      let events: [CalendarKitEvent] = [
         .init(calendar: self.calendar,
               id: "event1",
               title: "Sample",
               startDate: now,
               endDate: now.addingTimeInterval(3600),
               location: "Remote",
               notes: "Swift test")
      ]
      
      self.service = .init(calendars: [ calendar ],
                           events: events)
   }
   
   @Test("Should not throw when requesting access")
   func testAccessSuccess() async throws {
      try await service.setShouldThrow(false)
      try await service.requestAccess()
   }
   
   @Test("Should throw when access denied")
   func testAccessThrows() async throws {
      try await service.setShouldThrow(true)
      
      await #expect(throws: CalendarKitError.accessDenied) {
         try await service.requestAccess()
      }
      
      try await service.setShouldThrow(false)
   }
   
   @Test("Should return calendar list")
   func testFetchCalendars() async throws {
      let calendars = try await service.fetchCalendars()
      #expect(calendars.count == 1)
      #expect(calendars.first?.title == "Personal")
   }
   
   @Test("Should fetch events in calendar")
   func testFetchEventsInCalendar() async throws {
      let result = try await service.fetchEvents(calendarID: calendar.id,
                                                 from: now.addingTimeInterval(-60),
                                                 to: now.addingTimeInterval(4000))
      #expect(result.count == 1)
      #expect(result.first?.title == "Sample")
   }
   
   @Test("Should fetch all events")
   func testFetchAllEvents() async throws {
      let result = try await service.fetchEvents(from: now.addingTimeInterval(-60),
                                                 to: now.addingTimeInterval(4000))
      #expect(result.count == 1)
   }
   
   @Test("Should update an event")
   func testUpdateEvent() async throws {
      let endDate = now.addingTimeInterval(600)
      let addedEvent = CalendarKitEvent(calendar: self.calendar,
                                        id: UUID().uuidString,
                                        title: "New Event",
                                        startDate: now,
                                        endDate: endDate,
                                        location: "Times Square",
                                        notes: "Softball match")
      try await service.addEvent(event: addedEvent,
                                 to: calendar)
      
      let events = try await service.fetchEvents(from: now,
                                                 to: now.addingTimeInterval(3600))
      
      let outdatedEvent = try #require(events.first)
      let newEndDate = now.addingTimeInterval(1200)
      let updatedEvent = CalendarKitEvent(calendar: self.calendar,
                                          id: outdatedEvent.id,
                                          title: "Updated event",
                                          startDate: outdatedEvent.startDate,
                                          endDate: newEndDate,
                                          location: outdatedEvent.location,
                                          notes: outdatedEvent.notes)
      try await service.updateEvent(event: updatedEvent,
                                    of: calendar)
      
      let updatedEvents = try await service.fetchEvents(from: now,
                                                        to: now.addingTimeInterval(3600))
      let resultedEvent = updatedEvents.first { $0.title == "Updated event" }
      try #require(resultedEvent != nil)
   }
   
   @Test("Should add and delete event")
   func testAddAndDeleteEvent() async throws {
      let addedEvent = CalendarKitEvent(calendar: self.calendar,
                                        id: UUID().uuidString,
                                        title: "New Event",
                                        startDate: now,
                                        endDate: now.addingTimeInterval(600),
                                        location: "Times Square",
                                        notes: "Softball match")
      try await service.addEvent(event: addedEvent,
                                 to: calendar)
      
      let added = try await service.fetchEvents(from: now,
                                                to: now.addingTimeInterval(3600))
      #expect(added.contains { $0.title == "New Event" })
      
      let newEvent = added.first { $0.title == "New Event" }
      try #require(newEvent != nil)
      
      try await service.deleteEvent(with: newEvent!.id)
      
      let afterDelete = try await service.fetchEvents(from: now,
                                                      to: now.addingTimeInterval(3600))
      #expect(!afterDelete.contains { $0.id == newEvent!.id })
   }
   
   @Test("Should throw on deleting unknown event")
   func testDeleteUnknownEvent() async throws {
      await #expect(throws: CalendarKitError.eventNotFound) {
         try await service.deleteEvent(with: "non-existent")
      }
   }
}
