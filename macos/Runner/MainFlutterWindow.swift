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

  // Track lock state to control key/main window behavior
  private var isLocked: Bool = true

  // 항상 key window가 될 수 있어야 텍스트(비밀번호, 할일) 입력이 가능함
  override var canBecomeKey: Bool {
    return true
  }

  // 항상 main window가 될 수 있어야 정상 작동
  override var canBecomeMain: Bool {
    return true
  }

  private func setWindowLocked(_ locked: Bool) {
    isLocked = locked

    let currentFrame = self.frame

    if locked {
      // 1. Lock Mode: 고정된 위치지만 레벨은 normal
      self.level = .normal
    } else {
      // 2. Edit Mode: 드래그를 위해 플로팅 레벨
      self.level = .floating
    }

    // 포커스 강제
    self.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)

    self.setFrame(currentFrame, display: true)
    
    DispatchQueue.main.async { [weak self] in
      self?.setFrame(currentFrame, display: true)
    }
  }
}
