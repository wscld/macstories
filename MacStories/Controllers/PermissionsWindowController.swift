//
//  IntroWindowController.swift
//  MacStories
//
//  Created by Wesley Caldas on 27/03/25.
//

import Cocoa
import SwiftUI

class PermissionsWindowController: NSWindowController {
    static var shared: PermissionsWindowController?

    convenience init() {
        let view = PermissionsRequestView()
        let hostingController = NSHostingController(rootView: view)

        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = "About MacStories"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 300, height: 200))
        window.isReleasedWhenClosed = false

        self.init(window: window)
        PermissionsWindowController.shared = self
    }

    func showWindow() {
        self.window?.makeKeyAndOrderFront(nil)
    }
}
