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
    @State private var refreshKey = UUID()
    @State private var isSwitching = false // Track switching state
    
    var body: some View {
            VStack(spacing: -10) {
                ZStack {
                    if let previewLayer = recorder.previewLayer {
                        VideoPreviewView(previewLayer: previewLayer)
                            .frame(width: 320, height: 568)
                            .cornerRadius(10)
                            .animation(.bouncy, value: recorder.previewLayer)
                            .id(refreshKey)
                            .opacity(isSwitching ? 0.5 : 1.0) // Fade out during switch
                            .transition(.opacity) // Smooth fade transition
                            .onAppear {
                                print("Preview layer rendered in UI: \(previewLayer)")
                            }
                    } else {
                        VStack {
                            Text("Camera or Microphone Unavailable")
                                .font(.headline)
                            Text("Please grant camera and microphone permissions in System Settings > Privacy & Security.")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .padding(20)
                        }
                        .frame(width: 320, height: 568, alignment: .center)
                        .animation(.bouncy, value: recorder.previewLayer)
                        .background {
                            TranslucentBackgroundView()
                                .cornerRadius(16)
                        }
                        .onAppear {
                            print("Preview layer unavailable in UI")
                        }
                    }
                    
                    // Loading indicator during switch
                    if isSwitching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                            .frame(width: 320, height: 568)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: isSwitching) // Smooth animation
                
                VStack(spacing: 10) {
                    HStack(spacing:10){
                        Picker("", selection: $recorder.selectedCamera) {
                            ForEach(recorder.availableCameras, id: \.self) { camera in
                                Text(camera.localizedName).tag(camera as AVCaptureDevice?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: recorder.selectedCamera) { _ in
                            withAnimation {
                                isSwitching = true // Show loading
                            }
                            recorder.updateSession()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    isSwitching = false // Hide loading
                                    refreshKey = UUID() // Trigger redraw
                                }
                            }
                        }
                        
                        Picker("", selection: $recorder.selectedAudioDevice) {
                            ForEach(recorder.availableAudioDevices, id: \.self) { audio in
                                Text(audio.localizedName).tag(audio as AVCaptureDevice?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .onChange(of: recorder.selectedAudioDevice) { _ in
                            withAnimation {
                                isSwitching = true // Show loading
                            }
                            recorder.updateSession()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    isSwitching = false // Hide loading
                                    refreshKey = UUID() // Trigger redraw
                                }
                            }
                        }
                    }
                    
                    AudioWaveView(recorder: recorder)
                    RecorderView(recorder: recorder)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(20)
                .background {
                    TranslucentBackgroundView()
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 6)
                }
            }
            .padding(5)
            .frame(minWidth: 330, maxWidth: 330, minHeight: 780, maxHeight: 780)
            .windowResizeBehavior(.disabled)
            .onAppear {
                recorder.setupCamera()
                print("ContentView appeared, calling setupCamera")
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
