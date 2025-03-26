//
//  ContentView.swift
//  MacStories
//
//  Created by Wesley Caldas on 25/03/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    @StateObject private var recorder = VideoRecorder()
    
    var body: some View {
        VStack(spacing: 5) {
            // Webcam preview
            if let previewLayer = recorder.previewLayer {
                VideoPreviewView(previewLayer: previewLayer)
                    .frame(width: 320, height: 568) // Instagram Story aspect ratio (9:16)
                    .cornerRadius(10)
            } else {
                Text("Camera unavailable")
                    .frame(width: 320, height: 568,alignment: .center)
                
            }
            
            
            
            VStack(spacing: 10){
                AudioWaveView(recorder: recorder)
                RecorderView(recorder: recorder)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(20)
            .background {
                TranslucentBackgroundView()
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.88, green: 0.88, blue: 1), lineWidth: 0)
                    )
            }
            
        }
        .padding(5)
        .frame(minWidth:330,maxWidth:330,minHeight:750,maxHeight:750)
        .windowResizeBehavior(.disabled)
        .onAppear {
            recorder.setupCamera()
        }
    }
}

// Preview layer wrapper for SwiftUI
struct VideoPreviewView: NSViewRepresentable {
    let previewLayer: AVCaptureVideoPreviewLayer
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        previewLayer.frame = view.bounds
        view.layer = previewLayer
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        previewLayer.frame = nsView.bounds
    }
}

struct TranslucentBackgroundView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover // Best for dark translucent effects
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
