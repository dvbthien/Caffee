import Cocoa
import Combine
import Foundation
import Settings
import SwiftUI

// AppDelegate manages the application lifecycle and UI components like status bar and windows
class AppDelegate: NSObject, NSApplicationDelegate {

  var appState = AppState()

  var statusBar: NSStatusBar!
  var statusBarItem: NSStatusItem!
  var settingsWindowController: SettingsWindowController?

  private var cancellables = Set<AnyCancellable>()

  func applicationDidFinishLaunching(_ notification: Notification) {
    //    let permissionStatus = appState.checkPermissionStatus()
    let isTrusted = appState.eventHook.isTrusted(prompt: false)

    if isTrusted {
      // Set up the event hook if the process is trusted
      appState.storeTrustedAppVersion()
      appState.eventHook.setupEventTap(give: appState)

      // Init app
      initMenuBar()
      appState.load()
      appState.setEnabled(set: true)
      appState.registerSwitchFileMonitor()

    } else if appState.isNewAppVersion() {
      openUpgradeNewVersion()
    } else {
      initGuideMenuBar()
      openGuide()
    }
  }

  func initGuideMenuBar() {
    // Initialize status bar item with variable length
    statusBar = NSStatusBar.system
    statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

    // Configure status bar item
    if let button = statusBarItem.button {
      // Icon
      button.image = NSImage(
        systemSymbolName: "gear.badge.questionmark", accessibilityDescription: nil)?
        .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))

      // Create and set up the menu for the status bar item
      let menu = NSMenu()
      menu.addItem(
        withTitle: "Hướng dẫn cài đặt lần đầu", action: #selector(openGuide), keyEquivalent: "")
      menu.addItem(withTitle: "Quit App", action: #selector(quitApp), keyEquivalent: "q")
      statusBarItem.menu = menu
    }

  }

  func initMenuBar() {
    // Initialize status bar item with variable length
    statusBar = NSStatusBar.system
    statusBarItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)

    // Configure status bar item
    if let button = statusBarItem.button {
      // Icon
      let vIcon = NSImage(systemSymbolName: "v.square", accessibilityDescription: nil)?
        .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))
      let eIcon = NSImage(systemSymbolName: "e.square", accessibilityDescription: nil)?
        .withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))

      button.image = vIcon

      // Create and set up the menu for the status bar item
      let menu = NSMenu()
      menu.addItem(withTitle: "Tắt / Mở", action: #selector(changeCase), keyEquivalent: "")
      let telexMenuItem = menu.addItem(
        withTitle: "Kiểu Telex",
        action: #selector(changeToTelex), keyEquivalent: "")
      let vniMenuItem = menu.addItem(
        withTitle: "Kiểu VNI",
        action: #selector(changeToVNI), keyEquivalent: "")
      menu.addItem(NSMenuItem.separator())
      menu.addItem(withTitle: "Settings", action: #selector(openSettings), keyEquivalent: "")
      menu.addItem(withTitle: "Quit App", action: #selector(quitApp), keyEquivalent: "q")
      statusBarItem.menu = menu

      appState.$typingMethod.sink { newState in
        vniMenuItem.title = newState == .VNI ? "[✔] Kiểu VNI" : "Kiểu VNI"
        telexMenuItem.title = newState == .Telex ? "[✔] Kiểu Telex" : "Kiểu Telex"
      }.store(in: &cancellables)

      // Subcriber
      appState.$enabled.sink { newState in
        button.image = newState ? vIcon : eIcon
      }.store(in: &cancellables)

    }

    settingsWindowController = SettingsWindowController(
      panes: [
        Settings.Pane(
          identifier: Settings.PaneIdentifier("General"),
          title: "General",
          toolbarIcon: NSImage(systemSymbolName: "gear", accessibilityDescription: nil)!
        ) {
          GeneralView().environmentObject(appState)
        }
        //        Settings.Pane(
        //          identifier: Settings.PaneIdentifier("Macro"),
        //          title: "Macro",
        //          toolbarIcon: NSImage(systemSymbolName: "pianokeys", accessibilityDescription: nil)!
        //        ) {
        //          MacroView(appState: appState)
        //        },
      ],
      style: .toolbarItems
    )
  }

  // Opens settings in a new window
  @objc func openSettings() {
    settingsWindowController?.show()
    NSApp.activate(ignoringOtherApps: true)
  }

  // Opens guide
  @objc func openGuide() {
    let contentView = GuideView().environmentObject(appState)
    let windowController = WindowController()
    windowController.contentViewController = NSHostingController(rootView: contentView)
    windowController.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  // Opens guide
  @objc func openUpgradeNewVersion() {
    let contentView = UpgradeAppView().environmentObject(appState)
    let windowController = WindowController()
    windowController.contentViewController = NSHostingController(rootView: contentView)
    windowController.showWindow(nil)
    NSApp.activate(ignoringOtherApps: true)
  }

  @objc func changeToTelex() {
    appState.setTypingMethod(method: .Telex)
  }

  @objc func changeToVNI() {
    appState.setTypingMethod(method: .VNI)
  }

  // Toggles the title of the status bar item's button
  @objc func changeCase() {
    appState.setEnabled(set: !appState.enabled)

  }

  // Quits the application
  @objc func quitApp() {
    NSApp.terminate(self)
  }

  // Returns true to opt-in to secure coding for state restoration
  func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  // Cleans up before the application terminates
  func applicationWillTerminate(_ aNotification: Notification) {
    appState.eventHook.destroy()
  }
}
