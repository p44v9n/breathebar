import Cocoa

class ShadeWindow: NSWindow {

  static let defaultColor = NSColor.black.withAlphaComponent(0.9)
  private var animationDuration: TimeInterval
  var onDismiss: (() -> Void)?
  var onShadeClick: (() -> Void)?

  override var backgroundColor: NSColor! {
    didSet {
      self.alphaValue = 0  // Start with zero alpha
    }
  }

  init(animationDuration: TimeInterval = 0.3, onShadeClick: (() -> Void)? = nil) {
    self.animationDuration = animationDuration
    self.onShadeClick = onShadeClick
    let screen = NSScreen.main ?? NSScreen.screens.first!
    let frame = screen.frame

    super.init(
      contentRect: frame,
      styleMask: .borderless,
      backing: .buffered,
      defer: false)

    self.backgroundColor = ShadeWindow.defaultColor
    self.level = .floating
    self.isMovableByWindowBackground = false
    self.ignoresMouseEvents = false  // Change this to false
    self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

    // Ensure the window stays on top and covers the entire screen
    self.setFrame(frame, display: true)

    // Pass the onShadeClick closure to ShadeContentView
    self.contentView = ShadeContentView(onDismiss: { [weak self] in
      self?.onShadeClick?()
    })
  }

  func fadeIn(completion: (() -> Void)? = nil) {
    self.alphaValue = 0  // Ensure we start fully transparent
    self.orderFrontRegardless()

    // Use DispatchQueue to ensure the window is visible before animating
    DispatchQueue.main.async {
      NSAnimationContext.runAnimationGroup(
        { context in
          context.duration = self.animationDuration
          self.animator().alphaValue = self.backgroundColor.alphaComponent
        }, completionHandler: completion)
    }
  }

  func fadeOut(completion: (() -> Void)? = nil) {
    NSAnimationContext.runAnimationGroup(
      { context in
        context.duration = animationDuration
        self.animator().alphaValue = 0
      },
      completionHandler: {
        self.orderOut(nil)
        completion?()
      })
  }
}

class ShadeContentView: NSView {
  var onDismiss: (() -> Void)?

  init(onDismiss: @escaping () -> Void) {
    self.onDismiss = onDismiss
    super.init(frame: .zero)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func mouseDown(with event: NSEvent) {
    onDismiss?()
  }
}
