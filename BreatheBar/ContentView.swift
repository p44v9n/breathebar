import SwiftUI
import Combine

struct ContentView: View {
  @ObservedObject private var preferencesManager = PreferencesManager.shared
  @State private var preferencesWindowController: PreferencesWindowController?
  @State private var duration: (name: String, value: Int)
  @State private var animationVisible = false
  @Environment(\.presentationMode) var presentationMode
  @State private var expandMenu = true
  @State private var timer: Timer?
  @State private var shadeWindow: ShadeWindow?
  var onCloseShade: (() -> Void)?

  init() {
    let prefs = PreferencesManager.shared
    _duration = State(
      initialValue: (name: prefs.defaultDurationName, value: prefs.defaultDurationValue))
    _animationVisible = State(initialValue: false)
  }

  var body: some View {
    Group {
      if !animationVisible {
        mainView
      } else {
        animationView
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .startAnimationRequested)) { _ in
      if !animationVisible {
        showShadeWindow()
        animationVisible = true
        startTimer()
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .stopAnimationRequested)) { _ in
      closePopover()
    }
  }

  private var mainView: some View {
    VStack {
      HStack {
        durationPicker
        startButton
        menuButton
      }
      .clipped()

      if expandMenu {
        menuOptions
      }
    }.padding(10)
  }

  private var durationPicker: some View {
    Picker("How long:", selection: $duration.value) {
      Text("20 seconds").tag(20)
      Text("1 minute").tag(60)
      Text("3 minutes").tag(180)
    }
    .frame(maxWidth: 120)
    .labelsHidden()
    .onChange(of: duration.value) { newValue in
      duration.name = durationName(for: newValue)
    }

  }

  private var startButton: some View {
    Button(action: {
      if !animationVisible {
        showShadeWindow()
        animationVisible = true
        startTimer()
      } else {
        stopAnimation()
      }
    }) {
      Label("Start", systemImage: "play.fill")
    }
  }

  private func stopAnimation() {
    shadeWindow?.fadeOut {
      self.animationVisible = false
      self.timer?.invalidate()
      self.onCloseShade?()
    }
  }

  private var menuButton: some View {
    Button(action: {
      expandMenu.toggle()
    }) {
      Image(systemName: "ellipsis")
        .imageScale(.large)

    }

  }

  private var menuOptions: some View {
    HStack {
      Button(action: {
        showPreferences()
      }) {
        Label("Settings", systemImage: "gearshape.fill")
      }

      Button(action: {
        NSApplication.shared.terminate(nil)
      }) {
        Label("Quit", systemImage: "xmark.circle.fill")
      }
    }
  }

  private var animationView: some View {
    ZStack(alignment: .topLeading) {
      VStack {
        AnimationView(
          count: $duration.value,
          duration: $duration,
          isAnimating: $animationVisible,
          onComplete: closePopover
        )

        if PreferencesManager.shared.showBreathCount {
          Text("Remaining breaths: \(Int(ceil(Double(duration.value) / 6.0)))")
        }
      }

      closeButton
    }
    .frame(
      width: sizeForPopover().width,
      height: sizeForPopover().height
    )
    .padding(10)
  }

  private var closeButton: some View {
    Button {
      closePopover()
    } label: {
      Image(systemName: "xmark.circle.fill")
        .foregroundColor(Color(.darkGray))
        .imageScale(.large)
    }
    .buttonStyle(PlainButtonStyle())
    .padding(10)

  }

  private func showPreferences() {
    if preferencesWindowController == nil {
      preferencesWindowController = PreferencesWindowController()
    }
    preferencesWindowController?.showWindow(nil)
  }

  private func closePopover() {
    stopAnimation()
    duration = (
      name: preferencesManager.defaultDurationName, value: preferencesManager.defaultDurationValue
    )
    NotificationCenter.default.post(name: .popoverCloseRequested, object: nil)
    self.presentationMode.wrappedValue.dismiss()
  }

  private func startTimer() {
    timer?.invalidate()
    timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(duration.value), repeats: false) {
      _ in
      closePopover()
    }
  }

  private func sizeForPopover() -> (width: CGFloat, height: CGFloat) {
    switch preferencesManager.popoverSize {
    case "sm":
      return (width: 250, height: 250)
    case "md":
      return (width: 300, height: 300)
    case "lg":
      return (width: 350, height: 350)
    default:
      return (width: 250, height: 250)
    }
  }

  private func durationName(for value: Int) -> String {
    switch value {
    case 20: return "Short"
    case 60: return "Medium"
    case 180: return "Long"
    default: return "Custom"
    }
  }

  private func showShadeWindow() {
    if shadeWindow == nil {
      shadeWindow = ShadeWindow(onShadeClick: stopAnimation)
    }
    shadeWindow?.fadeIn()
  }
}

#Preview {
  ContentView()
}
