//
//  PermissionsView.swift
//  MacStories
//
//  Created by Wesley Caldas on 27/03/25.
//

import SwiftUI
import AVFoundation

struct PermissionsRequestView: View {
    @State private var cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    @State private var microphonePermissionStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    @State private var titleOpacity: Double = 0.0
    @State private var buttonScale: CGFloat = 0.8
    @State private var buttonOpacity: Double = 0.0
    @State private var loading = false
    var onReady : () -> ()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to MacStories")
                .font(.system(size: 24, weight: .bold))
                .opacity(titleOpacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        titleOpacity = 1.0
                    }
                }

            Text("We need your permission to access the camera and microphone to record videos.")
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)

            // Camera Permission Button
            PermissionButton(
                title: cameraPermissionStatus == .authorized ? "Camera Access Granted" : "Grant Camera Access",
                icon: "camera.fill",
                isGranted: cameraPermissionStatus == .authorized,
                action: {
                    requestCameraPermission()
                }
            )
            .scaleEffect(buttonScale)
            .opacity(buttonOpacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                    buttonScale = 1.0
                    buttonOpacity = 1.0
                }
            }

            // Microphone Permission Button
            PermissionButton(
                title: microphonePermissionStatus == .authorized ? "Microphone Access Granted" : "Grant Microphone Access",
                icon: "mic.fill",
                isGranted: microphonePermissionStatus == .authorized,
                action: {
                    requestMicrophonePermission()
                }
            )
            .scaleEffect(buttonScale)
            .opacity(buttonOpacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4)) {
                    buttonScale = 1.0
                    buttonOpacity = 1.0
                }
            }

            // Continue Button (only visible when both permissions are granted)
            if cameraPermissionStatus == .authorized && microphonePermissionStatus == .authorized && !loading {
                Button(action: {
                    loading.toggle()
                    onReady()
                }) {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(buttonScale)
                .opacity(buttonOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.6)) {
                        buttonScale = 1.0
                        buttonOpacity = 1.0
                    }
                }
            }
            
            if loading {
                Button(action: {
                    
                }) {
                    Text("Loading camera")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
                .scaleEffect(buttonScale)
                .disabled(true)
                .opacity(buttonOpacity)
                .onAppear {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.6)) {
                        buttonScale = 1.0
                        buttonOpacity = 1.0
                    }
                }
            }
        }
        .frame(width: 320, height: 568)
        .cornerRadius(10)
    }

    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
            }
        }
    }

    private func requestMicrophonePermission() {
        AVCaptureDevice.requestAccess(for: .audio) { granted in
            DispatchQueue.main.async {
                microphonePermissionStatus = AVCaptureDevice.authorizationStatus(for: .audio)
            }
        }
    }
}

// Reusable Permission Button View
struct PermissionButton: View {
    let title: String
    let icon: String
    let isGranted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isGranted ? .green : .blue)
                Text(title)
                    .foregroundColor(isGranted ? .green : .blue)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(isGranted ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isGranted) // Disable button if permission is already granted
    }
}

// Preview
struct PermissionsRequestView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionsRequestView{
            
        }
    }
}
