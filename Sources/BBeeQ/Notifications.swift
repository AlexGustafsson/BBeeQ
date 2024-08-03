import UserNotifications
import os

private let logger = Logger(
  subsystem: Bundle.main.bundleIdentifier!, category: "Notifications")

actor Notifications {
  public static let shared = Notifications()

  private var isAvailable = false

  public func requestAccess() {
    if isatty(STDOUT_FILENO) == 0 {
      logger.debug("Requesting notifications permissions")
      UNUserNotificationCenter.current()
        .requestAuthorization(options: [.sound, .badge]) { granted, error in
          if granted {
            logger.debug("Notification authorization granted")
            self.isAvailable = true
          } else {
            logger.debug(
              "Notification authorization denied. Error: \(error, privacy: .public)"
            )
          }
        }
    } else {
      print(
        "Running in a TTY - likely not from app bundle. Notifications will not work"
      )
      logger.warning(
        "Running in a TTY - likely not from app bundle. Notifications will not work"
      )
    }
  }

  public func addImmediate(
    identifier: String, content: UNMutableNotificationContent
  )
    async
  {
    if !self.isAvailable {
      logger.warning(
        "Failed to post notification - notifications not available")
      return
    }

    do {
      try await UNUserNotificationCenter.current()
        .add(
          UNNotificationRequest(
            identifier: identifier, content: content, trigger: nil))
    } catch {
      logger.error("Failed to post notification: \(error, privacy: .public)")
    }
  }
}
