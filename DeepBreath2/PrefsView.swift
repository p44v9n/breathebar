import LaunchAtLogin
import RiveRuntime
import SwiftUI

struct PrefsView: View {
  @StateObject private var preferencesManager = PreferencesManager.shared
  @State private var selectedTab = 0

  var body: some View {
    VStack(spacing: 0) {
      CustomTabBar(selectedTab: $selectedTab)
        .padding(.top, 5)

      content
      Spacer()
    }
    .frame(width: 500, height: 440)

  }

  @ViewBuilder
  private var content: some View {
    switch selectedTab {
    case 0:
      GeneralPrefsView(preferencesManager: preferencesManager)
    case 1:
      DisplayPrefsView(preferencesManager: preferencesManager)
    case 2:
      Text("Reminders are coming soon!")
    case 3:
      AboutPrefsView(preferencesManager: preferencesManager)
    default:
      EmptyView()
    }
  }
}

struct CustomTabBar: View {
  @Binding var selectedTab: Int

  var body: some View {
    HStack(spacing: 10) {
      TabBarButton(imageName: "tools", title: "General", isSelected: selectedTab == 0) {
        selectedTab = 0
      }
      TabBarButton(imageName: "display", title: "Display", isSelected: selectedTab == 1) {
        selectedTab = 1
      }
      TabBarButton(imageName: "clock", title: "Reminders", isSelected: selectedTab == 2) {
        selectedTab = 2
      }
      TabBarButton(imageName: "sun", title: "About", isSelected: selectedTab == 3) {
        selectedTab = 3
      }
    }
    .frame(width: 500, height: 60)

    .padding(20)
  }
}

struct TabBarButton: View {
  let imageName: String
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack {
        Image(imageName + (isSelected ? "-col" : "-grey")).resizable().frame(width: 40, height: 40)
        Text(title)
          .font(.caption)
      }
      .frame(width: 80)
      .padding(4)
    }

    .background(Color.clear)
  }
}

struct GeneralPrefsView: View {
  @ObservedObject var preferencesManager: PreferencesManager

  var body: some View {
    VStack(
      alignment: .leading, spacing: 15,
      content: {

        LaunchAtLogin.Toggle()

        HStack(
          alignment: .firstTextBaseline, spacing: 10,
          content: {
            Toggle(
              isOn: .constant(false),
              label: {
                Text("Check automatically for updates")
              }
            ).disabled(true)
            Button("Check now...") {}.disabled(true)
          }
        )
        Divider().frame(width: 440)
        // Picker("Default time:", selection: $preferencesManager.defaultDuration) {
        //   Text("20 seconds").tag(["Short", 20])
        //   Text("1 minute").tag(["Medium", 60])
        //   Text("3 minutes").tag(["Long", 180])
        // }.frame(width: 200)

        VStack(
          alignment: .leading, spacing: 5,
          content: {
            Toggle(
              isOn: .constant(false),
              label: {
                Text("Start On Press")
              }
            ).disabled(true)
            Text(
              "Start the animation straight away when clicking on the menu bar icon, instead of opening a menu."
            ).font(.system(size: 11)).foregroundStyle(Color.gray).fixedSize(
              horizontal: false, vertical: true
            ).frame(width: 420, alignment: .leading)
          })
        VStack(
          alignment: .leading, spacing: 5,
          content: {
            Toggle(
              isOn: .constant(false),
              label: {
                Text("Use audio cues")
              }
            ).disabled(true)
            Text(
              "Shut your eyes and take a break from the screen. Audio cues let you know when to breathe in and breathe out."
            ).font(.system(size: 11)).foregroundStyle(Color.gray).fixedSize(
              horizontal: false, vertical: true
            ).frame(width: 440, alignment: .leading)
          })

      })
  }
}

struct DisplayPrefsView: View {
  @ObservedObject var preferencesManager: PreferencesManager
  @State private var riveViewModel: RiveViewModel?
  @State private var animationUpdateTrigger = false  // Add this line

  var body: some View {
    VStack(alignment: .leading, spacing: 15) {
      Picker("Popover size:", selection: $preferencesManager.popoverSize) {
        Text("Small").tag("sm")
        Text("Medium").tag("md")
        Text("Large").tag("lg")
      }.frame(width: 200)

      Picker("Animation:", selection: $preferencesManager.animationStyle) {
        Text("Text").tag(1)
        Text("Triangles").tag(2)
        //        Text("Rings").tag(3)
      }.frame(width: 200)

      HStack(alignment: .top, spacing: 20) {
        Text("Preview:")

        if let riveViewModel = riveViewModel {
          riveViewModel.view()
            .frame(width: 100, height: 100)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .id(animationUpdateTrigger)
        } else {
          Text("Loading animation...")
        }
      }

      Divider().frame(width: 440)
      VStack(
        alignment: .leading, spacing: 5,
        content: {
          Toggle(
            isOn: .constant(false),
            label: {
              Text("Use custom timing")
            }
          ).disabled(true)
          Text("Set how long the in-breath, hold and out-breath take.").font(.system(size: 11))
            .foregroundStyle(Color.gray).fixedSize(horizontal: false, vertical: true).frame(
              width: 420, alignment: .leading)
        })
      VStack(
        alignment: .leading, spacing: 5,
        content: {
          Toggle(
            isOn: $preferencesManager.showBreathCount,
            label: {
              Text("Show how many breaths you have remaining")
            }
          )
          //          Text("Display a progress line underneath the animation to show how much longer you have.")
          //            .font(.system(size: 11)).foregroundStyle(Color.gray).fixedSize(
          //              horizontal: false, vertical: true)
          .frame(width: 420, alignment: .leading)
          .disabled(true)

        })
      VStack(
        alignment: .leading, spacing: 5,
        content: {
          Toggle(
            isOn: $preferencesManager.showBreathCount,
            label: {
              Text("Blackout the rest of the screen")
            }
          )
          .frame(width: 420, alignment: .leading)
          .disabled(true)

        })

    }
    .onAppear {
      updateRiveViewModel()
    }
    .onChange(of: preferencesManager.animationStyle) { _ in
      updateRiveViewModel()
    }
  }

  private func updateRiveViewModel() {
    let fileName: String
    switch preferencesManager.animationStyle {
    case 1:
      fileName = "breathing1"
    case 2:
      fileName = "breathing2"
    case 3:
      fileName = "breathing3"
    default:
      fileName = "breathing1"
    }
    self.riveViewModel = RiveViewModel(fileName: fileName)
    self.riveViewModel?.play(animationName: "6 seconds")
    animationUpdateTrigger.toggle()  // Add this line
  }
}

struct AboutPrefsView: View {
  @ObservedObject var preferencesManager: PreferencesManager
  @State private var riveViewModel: RiveViewModel?

  var body: some View {
    VStack(content: {

      if let riveViewModel = riveViewModel {
        riveViewModel.view()
          .frame(width: 100, height: 100)
          .cornerRadius(10)

      } else {
        Text("Loading animation...")
          .onAppear {
            self.riveViewModel = RiveViewModel(fileName: "breathing1")
            self.riveViewModel?.play(animationName: "6 seconds")
          }
      }
    }).padding(.top, 15).padding(.bottom, 25)

    VStack(
      spacing: 15,

      content: {
        Text("**Deep Breath**").font(.system(size: 17))
        Text("􀪥 Contribute on [GitHub](https://github.com/p44v9n/deepbreath).")
        Text("􁞵 Donate with [Ko-fi](https://ko-fi.com/p44v9n/).")
        Text("􀟱 Made by [Paavan](https://paavandesign.com)")
      })
  }
}

#Preview {
  PrefsView()
}
