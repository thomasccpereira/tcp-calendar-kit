# Privacy Policy

**tcp-calendar-kit** is an open-source Swift package. This document describes what data the package accesses and how it is handled.

## Data Access

This package uses Apple's **EventKit** framework to interact with the device's calendar system. It may access:

- Calendar metadata (title, source, color)
- Calendar events (title, dates, location, notes)

## Data Collection

**tcp-calendar-kit does not collect, store, transmit, or share any user data.**

All calendar data accessed through this package remains on the user's device and is processed exclusively within the app that integrates it. No data is sent to external servers by this package.

## Permissions

This package requests full calendar access via `EKEventStore.requestFullAccessToEvents`. The app integrating this package is responsible for:

- Adding `NSCalendarsFullAccessUsageDescription` to its `Info.plist`
- Providing a clear and accurate usage description to the user
- Handling permission denial gracefully

## Responsibility

The privacy practices of the app that integrates **tcp-calendar-kit** are the sole responsibility of its developer. This package provides only the interface to EventKit — how data is used, stored, or shared beyond that is determined by the integrating app.

## Contact

For questions or concerns, open an issue at [github.com/thomasccpereira/tcp-calendar-kit](https://github.com/thomasccpereira/tcp-calendar-kit).
