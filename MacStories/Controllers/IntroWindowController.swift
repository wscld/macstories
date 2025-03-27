//
//  IntroWindowController.swift
//  MacStories
//
//  Created by Wesley Caldas on 27/03/25.
//

import Cocoa
import SwiftUI

class IntroWindowController: NSWindowController {
    static var shared: IntroWindowController?

    convenience init() {
        let introView = IntroView()
        let hostingController = NSHostingController(rootView: introView)

        let window = NSWindow(
            contentViewController: hostingController
        )
        window.title = "About MacStories"
        window.styleMask = [.titled, .closable]
        window.setContentSize(NSSize(width: 300, height: 200))
        window.isReleasedWhenClosed = false

        self.init(window: window)
        IntroWindowController.shared = self
    }

    func showWindow() {
        self.window?.makeKeyAndOrderFront(nil)
    }
}
