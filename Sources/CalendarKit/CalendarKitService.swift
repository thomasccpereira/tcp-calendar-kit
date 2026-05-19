import EventKit

// Live implementation of `CalendarServiceProtocol` using EventKit.
public actor CalendarKitService: CalendarKitServiceProtocol {
   private let eventStore = EKEventStore()
   
   public init() { }
   
   // MARK: - Request Calendar permission
   public func requestAccess() async throws {
      let granted = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
         eventStore.requestFullAccessToEvents { granted, error in
            if let error = error {
               continuation.resume(throwing: error)
            } else {
               continuation.resume(returning: granted)
            }
         }
      }
      
      if !granted {
         throw CalendarKitError.accessDenied
      }
   }
   
   // MARK: - Fetching
   // Calendars
   public func fetchCalendars() async throws -> [CalendarKit] {
      eventStore.calendars(for: .event).map(CalendarKit.init(calendar:))
   }
   
   public func getCalendar(calendarID: String) async throws -> CalendarKit? {
      eventStore.calendar(withIdentifier: calendarID).map(CalendarKit.init(calendar:))
   }
   
   // All events in a range
   public func fetchEvents(calendarID: String?,
                           from startDate: Date,
                           to endDate: Date) async throws -> [CalendarKitEvent] {
      var calendars: [EKCalendar] = eventStore.calendars(for: .event)
      // Check if calendar with identifier exists
      if let calendarID {
         guard let calendar = eventStore.calendar(withIdentifier: calendarID) else {
            throw CalendarKitError.calendarNotFound
         }
         
         calendars = [ calendar ]
      }
      
      let predicate = eventStore.predicateForEvents(withStart: startDate,
                                                    end: endDate,
                                                    calendars: calendars)
      
      return eventStore.events(matching: predicate).map(CalendarKitEvent.init(event:))
   }
   
   // MARK: - CRUD
   // Add
   public func addEvent(event: CalendarKitEvent,
                        to calendar: CalendarKit) async throws {
      guard let calendar = eventStore.calendar(withIdentifier: calendar.id) else {
         throw CalendarKitError.calendarNotFound
      }
      
      let addedEvent = EKEvent(eventStore: eventStore)
      addedEvent.calendar = calendar
      addedEvent.title = event.title
      addedEvent.startDate = event.startDate
      addedEvent.endDate = event.endDate
      addedEvent.location = event.location
      addedEvent.notes = event.notes
      
      do {
         try eventStore.save(addedEvent, span: .thisEvent)
         
      } catch {
         throw CalendarKitError.failedToSave(error)
      }
   }
   
   // Update
   public func updateEvent(event: CalendarKitEvent,
                           of calendar: CalendarKit) async throws {
      guard let existing = eventStore.event(withIdentifier: event.id) else {
         throw CalendarKitError.eventNotFound
      }
      
      existing.title = event.title
      existing.startDate = event.startDate
      existing.endDate = event.endDate
      existing.location = event.location
      existing.notes = event.notes
      
      do {
         try eventStore.save(existing, span: .thisEvent)
      } catch {
         throw CalendarKitError.failedToSave(error)
      }
   }
   
   // Delete event
   public func deleteEvent(with eventID: String) async throws {
      guard let event = eventStore.event(withIdentifier: eventID) else {
         throw CalendarKitError.eventNotFound
      }
      
      do {
         try eventStore.remove(event, span: .thisEvent)
         
      } catch {
         throw CalendarKitError.failedToDelete(error)
      }
   }
}
