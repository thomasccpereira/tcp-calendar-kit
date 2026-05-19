# tcp-calendar-kit

A Swift actor-based EventKit wrapper for iOS. Provides a clean, protocol-oriented API for requesting calendar access, fetching calendars and events, and performing CRUD operations — fully abstracted from EventKit for easy testing via dependency injection.

## Requirements

- iOS 18.0+
- Swift 6.1+

## Dependencies

- [tcp-core-resources](https://github.com/thomasccpereira/tcp-core-resources)

## Installation

### Swift Package Manager

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/thomasccpereira/tcp-calendar-kit", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** and enter the repository URL.

### Privacy

This package uses `EventKit` to access the user's calendar. Add the following key to your app's `Info.plist`:

```xml
<key>NSCalendarsFullAccessUsageDescription</key>
<string>This app needs access to your calendar to manage events.</string>
```

---

## Usage

### Setup

```swift
let service: CalendarKitServiceProtocol = CalendarKitService()
```

### Request access

```swift
try await service.requestAccess()
```

Throws `CalendarKitError.accessDenied` if the user denies permission.

### Fetch calendars

```swift
let calendars: [CalendarKit] = try await service.fetchCalendars()

// Get a specific calendar by ID
let calendar: CalendarKit? = try await service.getCalendar(calendarID: "some-id")
```

### Fetch events

```swift
// All calendars
let events = try await service.fetchEvents(
    from: Date(),
    to: Date().addingTimeInterval(7 * 24 * 3600)
)

// Specific calendar
let events = try await service.fetchEvents(
    calendarID: calendar.id,
    from: Date(),
    to: Date().addingTimeInterval(7 * 24 * 3600)
)
```

### Add an event

```swift
let event = CalendarKitEvent(
    calendar: calendar,
    id: UUID().uuidString,
    title: "Team Meeting",
    startDate: startDate,
    endDate: endDate,
    location: "Conference Room",
    notes: "Quarterly review"
)

try await service.addEvent(event: event, to: calendar)
```

### Update an event

```swift
let updated = CalendarKitEvent(
    calendar: event.calendar,
    id: event.id,
    title: "Team Meeting (updated)",
    startDate: event.startDate,
    endDate: event.endDate,
    location: event.location,
    notes: event.notes
)

try await service.updateEvent(event: updated, of: calendar)
```

### Delete an event

```swift
try await service.deleteEvent(with: event.id)
```

---

## Entities

### CalendarKit

A `Sendable`, `Equatable` domain model representing a calendar:

```swift
public struct CalendarKit: Equatable, Sendable {
    public let id: String
    public let title: String
    public let source: String   // e.g. "iCloud", "Gmail"
    public let colorHex: String?
}
```

### CalendarKitEvent

A `Sendable`, `Equatable` domain model representing a calendar event:

```swift
public struct CalendarKitEvent: Equatable, Sendable {
    public let calendar: CalendarKit
    public let id: String
    public let title: String
    public let startDate: Date
    public let endDate: Date
    public let location: String?
    public let notes: String?
}
```

Both entities are initialized directly from their `EKCalendar` and `EKEvent` counterparts, keeping EventKit contained within the package.

---

## Dependency Injection & Testing

`CalendarKitServiceProtocol` makes the service fully replaceable in tests or previews:

```swift
public protocol CalendarKitServiceProtocol: Sendable {
    func requestAccess() async throws
    func fetchCalendars() async throws -> [CalendarKit]
    func getCalendar(calendarID: String) async throws -> CalendarKit?
    func fetchEvents(calendarID: String?, from: Date, to: Date) async throws -> [CalendarKitEvent]
    func addEvent(event: CalendarKitEvent, to: CalendarKit) async throws
    func updateEvent(event: CalendarKitEvent, of: CalendarKit) async throws
    func deleteEvent(with eventID: String) async throws
}
```

The package ships with a `MockCalendarService` actor in the test target, ready to use as a reference for your own mocks.

---

## Error Handling

All operations throw `CalendarKitError`:

| Case | Description |
|---|---|
| `.accessDenied` | User denied calendar permission |
| `.calendarNotFound` | No calendar found for the given ID |
| `.eventNotFound` | No event found for the given ID |
| `.failedToSave(Error)` | EventKit failed to save the event |
| `.failedToDelete(Error)` | EventKit failed to delete the event |

---

## Privacy

This package accesses the user's calendar via EventKit.
See [PRIVACY.md](PRIVACY.md) for full details.

---

## License

MIT
