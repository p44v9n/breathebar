import LaunchAtLogin
import RiveRuntime
import SwiftUI

struct WelcomeView: View {
  @State private var currentStep = 0
  @State private var riveText = RiveViewModel(fileName: "breathing_text")
  @State private var riveOrb = RiveViewModel(fileName: "breathing_orb")
  @StateObject private var preferencesManager = PreferencesManager.shared
  @State private var rotation: Double = 0
  @State private var launchAtLogin = false
  @State private var selectedAnimationStyle: Int = 1  // Default to 1

  var body: some View {
    Group {
      VStack {
        switch currentStep {
        case 0:
          firstStep
        case 1:
          secondStep
        case 2:
          thirdStep
        default:
          Text("Invalid step")
        }
      }
      .frame(width: 400, height: 300)
      .background(Color(NSColor.windowBackgroundColor))
    }
    .frame(width: 400, height: 300)
    .fixedSize()
    .onAppear {
      selectedAnimationStyle = preferencesManager.animationStyle  // Initialize with current preference
    }
  }

  var firstStep: some View {
    VStack {
      // if let appIcon = NSImage(named: NSImage.applicationIconName) {
        Image("logo")
          .resizable()
          .scaledToFill()
          .frame(width: 100, height: 100)

          .rotationEffect(.degrees(rotation))
          .onAppear {
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
              rotation = 360
            }
          }

      Text("Welcome to BreatheBar")
        .font(.title)
        .padding()

      Button("Continue") {
        currentStep += 1
      }
      
    }
    .frame(width: 400)
  }

  var secondStep: some View {
      VStack(spacing: 0) {
        VStack {
//            Spacer()
          Text("Choose Your Look")
            .font(.title3)
            .multilineTextAlignment(.center)
            .padding(.top, 40)
          HStack(spacing: 20) {
            AnimationStyleButton(
              riveViewModel: riveOrb,
              animationStyle: 1,
              selectedStyle: $selectedAnimationStyle
            )
            AnimationStyleButton(
              riveViewModel: riveText,
              animationStyle: 2,
              selectedStyle: $selectedAnimationStyle
            )
          }
          .padding()
            Spacer()
        }
          Spacer()
        Divider()
          Spacer()
          
          HStack {
            Spacer()
            
            Button("Continue") {
              currentStep += 1
            }

          }
          .padding()
      
        .background(Color(NSColor.windowBackgroundColor))
      }
  
    
  }
  var thirdStep: some View {
      VStack(spacing: 0) {
        VStack {
          Text("To start using BreatheBar,\nclick on this icon in your menu bar.")
            .multilineTextAlignment(.center)
            .padding(.top, 40)
          Spacer()
        }
        .frame(width: 400, height: 250.0)
        .background(
          Image("Welcome")
            .resizable()
            .scaledToFill()
        )
          Spacer()
                  Divider()
          
                    

          HStack {
            LaunchAtLogin.Toggle()
              .padding()
            Spacer()
            Button("Start") {
              preferencesManager.animationStyle = selectedAnimationStyle
              NSApplication.shared.keyWindow?.close()
            }
            .padding()
          }
          .background(Color(NSColor.windowBackgroundColor))
        Spacer()
      }
  .frame(width: 400)
}

}

struct AnimationStyleButton: View {
  let riveViewModel: RiveViewModel
  let animationStyle: Int
  @Binding var selectedStyle: Int

  var body: some View {
    Button(action: {
      selectedStyle = animationStyle
    }) {
      ZStack {
        riveViewModel.view()
          .allowsHitTesting(false)  // This allows the click to pass through
        
        RoundedRectangle(cornerRadius: 10)
          .fill(Color.clear)  // Invisible fill to capture clicks
      }
      .frame(width: 100, height: 100)
      .background(Color.secondary.opacity(0.2))
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(selectedStyle == animationStyle ? Color.accentColor : Color.clear, lineWidth: 3)
      )
    }
    .buttonStyle(PlainButtonStyle())
  }
}

#Preview {
  WelcomeView()
}
