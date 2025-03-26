//
//  AboutWindowController.swift
//  MacStories
//
//  Created by Wesley Caldas on 26/03/25.
//

import Cocoa
import SwiftUI

class AboutWindowController: NSWindowController {
    static var shared: AboutWindowController?

    convenience init() {
        let aboutView = AboutView()
        let hostingController = NSHostingController(rootView: aboutView)

        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = "About MacStories"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 300, height: 200))
        window.isReleasedWhenClosed = false

        self.init(window: window)
        AboutWindowController.shared = self
    }

    func showWindow() {
        self.window?.makeKeyAndOrderFront(nil)
    }
}
