import Cocoa
import SwiftUI

class PopoverManager: ObservableObject {
  private var statusItem: NSStatusItem?
  private var popover: NSPopover
  private var shadeWindow: ShadeWindow?
  private var reminderTimer: Timer?

  @ObservedObject private var preferencesManager = PreferencesManager.shared

  init() {
    popover = NSPopover()
    let contentView = ContentView()

    popover.behavior = .transient
    popover.contentViewController = NSHostingController(rootView: contentView)
//    popover.delegate = self

    createStatusBarItem()
    setupReminderTimer()

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(setupReminderTimer),
      name: NSApplication.didBecomeActiveNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handlePopoverCloseRequested),
      name: .popoverCloseRequested,
      object: nil
    )
  }

  private func createStatusBarItem() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    if let button = statusItem?.button {
      button.image = NSImage(named: "MenuBarIcon")
      button.image?.isTemplate = true
      button.action = #selector(togglePopover(_:))
      button.target = self
      // Respond to both left and right clicks
      button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }
  }

  @objc public func togglePopover(_ sender: AnyObject?) {
    if let button = statusItem?.button {
      let event = NSApp.currentEvent
      let isRightClick = (event?.type == .rightMouseUp) || (event?.modifierFlags.contains(.control) ?? false)
      if popover.isShown {
        // Left click toggles close; right click keeps the popover open
        if !isRightClick {
          NotificationCenter.default.post(name: .stopAnimationRequested, object: nil)
          if popover.isShown {
            popover.performClose(nil)
          }
        }
      } else {
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        if !isRightClick, preferencesManager.startOnPress, sender != nil {
          // Only auto-start when invoked by clicking the status bar icon (sender is not nil)
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            NotificationCenter.default.post(name: .startAnimationRequested, object: nil)
          }
        }
      }
    }
  }

  // MARK: - NSPopoverDelegate
  func popoverDidShow(_ notification: Notification) { }

  func popoverDidClose(_ notification: Notification) { }

  // MARK: - Notifications
  @objc private func handlePopoverCloseRequested() {
    if popover.isShown {
      popover.performClose(nil)
    } else {
      // Popover not shown; nothing to do
    }
  }

    @objc private func setupReminderTimer() {
    reminderTimer?.invalidate()

    guard preferencesManager.enableHourlyReminders else { return }

    let nextReminderDate = calculateNextReminderDate()
    let delay = nextReminderDate.timeIntervalSinceNow

    reminderTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
      self?.showReminder()
      self?.setupReminderTimer()  // Set up the next reminder
    }
  }

  private func calculateNextReminderDate() -> Date {
    let calendar = Calendar.current
    let now = Date()
    var components = calendar.dateComponents([.year, .month, .day, .hour], from: now)

    components.minute = preferencesManager.reminderMinute
    components.second = 0

    var nextReminderDate = calendar.date(from: components)!

    if nextReminderDate <= now {
      nextReminderDate = calendar.date(byAdding: .hour, value: 1, to: nextReminderDate)!
    }

    return nextReminderDate  // Add this line
  }

  private func setupHourlyReminderTimer() {
    reminderTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
      self?.showReminder()
    }
  }

  private func showReminder() {
    if let button = statusItem?.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
      // Reminders should always start the animation automatically
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        NotificationCenter.default.post(name: .startAnimationRequested, object: nil)
      }
    }
  }

  @objc private func reminderSettingsChanged() {
    setupReminderTimer()
  }

  // Add this method to update the reminder timer when preferences change
  func updateReminderSettings() {
    setupReminderTimer()
  }
}
