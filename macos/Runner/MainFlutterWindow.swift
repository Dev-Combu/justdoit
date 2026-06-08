import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    // Make the native window background clear and transparent
    flutterViewController.backgroundColor = .clear
    self.backgroundColor = NSColor.clear
    self.isOpaque = false
    
    // Hide native title bar controls for a clean widget appearance
    self.titlebarAppearsTransparent = true
    self.titleVisibility = .hidden

    // Register MethodChannel to communicate lock state from Flutter Dart code
    let channel = FlutterMethodChannel(
      name: "com.example.justdoit/window",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      if call.method == "setWindowLocked" {
        if let args = call.arguments as? [String: Any],
           let locked = args["locked"] as? Bool {
          self.setWindowLocked(locked)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Arguments must be a boolean dictionary", details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    // Default to locked behavior at startup (will be synchronized by Dart)
    self.setWindowLocked(true)

    super.awakeFromNib()
  }

  private func setWindowLocked(_ locked: Bool) {
    // Save current frame to prevent macOS from resetting/snapping window size during level changes
    let currentFrame = self.frame

    if locked {
      // 1. Lock Mode: pin to below normal level (always on bottom but still interactive)
      self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
      self.level = NSWindow.Level(rawValue: NSWindow.Level.normal.rawValue - 1)
    } else {
      // 2. Edit Mode: normal floating window (always on top of normal windows so it's easy to drag and resize)
      self.collectionBehavior = [.managed, .participatesInCycle]
      self.level = .floating
    }

    // Re-apply frame immediately
    self.setFrame(currentFrame, display: true)
    
    // Also re-apply on the next main loop run to counter any deferred system-initiated frame resets
    DispatchQueue.main.async { [weak self] in
      self?.setFrame(currentFrame, display: true)
    }
  }
}
