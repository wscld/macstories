//
//  MacStoriesApp.swift
//  MacStories
//
//  Created by Wesley Caldas on 25/03/25.
//

import SwiftUI


@main
struct MacStoriesApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView().background(TranslucentBackgroundView()) // Apply translucency
        }.windowStyle(HiddenTitleBarWindowStyle()) // Hide title bar for better aesthetics
    }
}

// AppDelegate to control NSWindow
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.setContentSize(NSSize(width: 330, height: 750))
            window.minSize = NSSize(width: 330, height: 750)
            window.maxSize = NSSize(width: 330, height: 750)
            window.styleMask.remove(.resizable) // Prevent resizing
            
            window.isOpaque = false
            window.backgroundColor = NSColor.black.withAlphaComponent(0.8) // Adjust transparency
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
        }
    }
    
    private struct TranslucentBackgroundView: NSViewRepresentable {
        func makeNSView(context: Context) -> NSVisualEffectView {
            let view = NSVisualEffectView()
            view.material = .dark // Best for dark translucent effects
            view.blendingMode = .behindWindow
            view.state = .active
            return view
        }

        func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
    }
}
