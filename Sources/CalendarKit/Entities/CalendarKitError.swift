// CalendarKit-specific error cases.
public enum CalendarKitError: Error, Equatable {
   public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.accessDenied, .accessDenied): true
      case (.calendarNotFound, .calendarNotFound): true
      case (.eventNotFound, .eventNotFound): true
      case (.failedToSave, .failedToSave): true
      case (.failedToDelete, .failedToDelete): true
      default: false
      }
   }
   
   case accessDenied
   case calendarNotFound
   case eventNotFound
   case failedToSave(Error)
   case failedToDelete(Error)
}
