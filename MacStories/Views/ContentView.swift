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
    @State private var isSwitching = false
    @EnvironmentObject private var appState: AppState // Access shared state
    
    var body: some View {
        VStack(spacing: -15) {
            ZStack {
                if let previewLayer = recorder.previewLayer {
                    VideoPreviewView(previewLayer: previewLayer)
                        .frame(width: 320, height: 568)
                        .cornerRadius(10)
                        .animation(.bouncy, value: recorder.previewLayer)
                        .id(refreshKey)
                        .opacity(isSwitching ? 0.5 : 1.0)
                        .transition(.opacity)
                        .onAppear {
                            print("Preview layer rendered in UI: \(previewLayer)")
                        }
                } else {
                    VStack {
                        PermissionsRequestView {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                recorder.setupCamera(askPermission: true)
                            }
                        }
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
                
                if isSwitching {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .frame(width: 320, height: 568)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isSwitching)
            
            if appState.showPickers && !recorder.isRecording && recorder.isCameraAvailable {
                HStack(spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Camera")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Picker("", selection: $recorder.selectedCamera) {
                            ForEach(recorder.availableCameras, id: \.self) { camera in
                                Text(camera.localizedName).tag(camera as AVCaptureDevice?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: 150)
                        .onChange(of: recorder.selectedCamera) { _ in
                            withAnimation {
                                isSwitching = true
                            }
                            recorder.updateSession()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    isSwitching = false
                                    refreshKey = UUID()
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Audio")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Picker("", selection: $recorder.selectedAudioDevice) {
                            ForEach(recorder.availableAudioDevices, id: \.self) { audio in
                                Text(audio.localizedName).tag(audio as AVCaptureDevice?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: 150)
                        .onChange(of: recorder.selectedAudioDevice) { _ in
                            withAnimation {
                                isSwitching = true
                            }
                            recorder.updateSession()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    isSwitching = false
                                    refreshKey = UUID()
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .padding(.top, 15)
                .padding(.bottom, 25)
                .zIndex(10)
                .background {
                    TranslucentBackgroundView()
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 6)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            VStack(spacing: 10) {
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
        .frame(minWidth: 340, maxWidth: 340, minHeight: 730, maxHeight: 730)
        .background(WindowResizeAndFullscreenDisabler()) // Add this to disable resizing
        .animation(.easeInOut(duration: 0.3), value: appState.showPickers)
        .onAppear(){
            recorder.setupCamera()
            print("ContentView appeared, calling setupCamera")
            let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore5")
            if !hasLaunchedBefore {
                IntroWindowController.shared?.showWindow() ?? IntroWindowController().showWindow()
                UserDefaults.standard.set(true, forKey: "hasLaunchedBefore5")
            }
        }.alert(isPresented: $recorder.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(recorder.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

struct WindowResizeAndFullscreenDisabler: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                // Disable resizing
                window.styleMask.remove(.resizable)
                // Disable fullscreen button
                window.collectionBehavior = .managed // Remove fullscreen capability
                window.styleMask.remove(.fullScreen) // Ensure no fullscreen option
                window.setContentSize(NSSize(width: 340, height: 730)) // Enforce fixed size
                // Optionally hide the fullscreen button visually
                window.standardWindowButton(.zoomButton)?.isHidden = true
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
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
        view.material = .popover
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(AppState())
    }
}
