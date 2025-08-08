import SwiftUI

class PreferencesManager: ObservableObject {
  @AppStorage("defaultDurationName") var defaultDurationName: String = "Short"
  @AppStorage("defaultDurationValue") var defaultDurationValue: Int = 60

  var defaultDuration: (name: String, value: Int) {
    get { (defaultDurationName, defaultDurationValue) }
    set {
      defaultDurationName = newValue.name
      defaultDurationValue = newValue.value
      objectWillChange.send()
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
