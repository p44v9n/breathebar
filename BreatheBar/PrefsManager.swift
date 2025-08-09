import SwiftUI

class PreferencesManager: ObservableObject {
  @AppStorage("defaultDurationName") var defaultDurationName: String = "Medium"
  @AppStorage("defaultDurationValue") var defaultDurationValue: Int = 60 {
    didSet {
      // Keep the human-friendly name in sync whenever the stored value changes
      defaultDurationName = PreferencesManager.durationName(for: defaultDurationValue)
      objectWillChange.send()
    }
  }

  var defaultDuration: (name: String, value: Int) {
    get { (defaultDurationName, defaultDurationValue) }
    set {
      defaultDurationName = newValue.name
      defaultDurationValue = newValue.value
      objectWillChange.send()
    }
  }

  /// Maps seconds to the human-friendly duration name used by animations/state machines
  static func durationName(for value: Int) -> String {
    switch value {
    case 20: return "Short"
    case 60: return "Medium"
    case 180: return "Long"
    default: return "Custom"
    }
  }

  @AppStorage("checkForUpdates") var checkForUpdates: Bool = false
  @AppStorage("popoverSize") var popoverSize: String = "sm"
  @AppStorage("menuBarIcon") var menuBarIcon: String = "Monochrome"
  @AppStorage("showBreathCount") var showBreathCount: Bool = false
  @AppStorage("startOnPress") var startOnPress: Bool = true
  @AppStorage("animationStyle") var animationStyle: Int = 1
  @AppStorage("timeBreatheIn") var timeBreatheIn: Int = 5
  @AppStorage("timeBreatheHold") var timeBreatheHold: Int = 5
  @AppStorage("timeBreatheOut") var timeBreatheOut: Int = 5

  @AppStorage("enableHourlyReminders") var enableHourlyReminders: Bool = false {
    didSet {
      NotificationCenter.default.post(name: .reminderSettingsChanged, object: nil)
    }
  }
  @AppStorage("reminderMinute") var reminderMinute: Int = 0 {
    didSet {
      NotificationCenter.default.post(name: .reminderSettingsChanged, object: nil)
    }
  }

  static let shared = PreferencesManager()

  private init() {}
}

extension Notification.Name {
  static let reminderSettingsChanged = Notification.Name("reminderSettingsChanged")
  static let startAnimationRequested = Notification.Name("startAnimationRequested")
  static let stopAnimationRequested = Notification.Name("stopAnimationRequested")
  static let popoverCloseRequested = Notification.Name("popoverCloseRequested")
}
