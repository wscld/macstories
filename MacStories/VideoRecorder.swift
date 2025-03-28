//
//  VideoRecorder.swift
//  MacStories
//
//  Created by Wesley Caldas on 25/03/25.
//

import AVFoundation
import Foundation
import SwiftUI

class VideoRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var isSaving = false
    @Published var isCameraAvailable = false
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    @Published var audioLevel: Float = 0.0 // For audio wave visualization
    @Published var maxDuration: Int = 60
    @Published var timeRemaining: Int = 60
    @Published var availableCameras: [AVCaptureDevice] = []
    @Published var availableAudioDevices: [AVCaptureDevice] = []
    @Published var selectedCamera: AVCaptureDevice?
    @Published var selectedAudioDevice: AVCaptureDevice?
    
    private var timerCountdown:Timer?
    private var captureSession: AVCaptureSession?
    private var movieOutput: AVCaptureMovieFileOutput?
    private var audioRecorder: AVAudioRecorder?
    private var levelTimer: Timer?
    
    func fetchDevices() {
        // Fetch available cameras
        let cameraDiscovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera],
            mediaType: .video,
            position: .unspecified
        )
        availableCameras = cameraDiscovery.devices
        
        // Fetch available audio devices
        let audioDiscovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInMicrophone, .externalUnknown],
            mediaType: .audio,
            position: .unspecified
        )
        availableAudioDevices = audioDiscovery.devices
        
        guard let defaultAudioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: defaultAudioDevice) else {
            print("Failed to initialize audio device")
            return
        }
        
        // Set defaults if not already selected
        if selectedCamera == nil, let defaultCamera = availableCameras.first {
            selectedCamera = defaultCamera
        }
        if selectedAudioDevice == nil {
            selectedAudioDevice = defaultAudioDevice
        }
    }
    
    func setupCamera() {
        // Check current authorization status for video
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // Video permission already granted, check audio
            checkAudioPermission()
        case .notDetermined:
            print("Video permission not set, handling via UI button")
        case .denied, .restricted:
            print("Video permission denied or restricted")
            DispatchQueue.main.async {
                self.isCameraAvailable = false
            }
        @unknown default:
            fatalError("Unknown video authorization status")
        }
    }
    
    private func checkAudioPermission() {
        // Check current authorization status for audio
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            // Both permissions granted, initialize session
            DispatchQueue.main.async {
                self.initializeSession()
            }
        case .notDetermined:
            // Request audio permission
            print("Audio permission not set, handling via UI button")
        case .denied, .restricted:
            print("Audio permission denied or restricted")
            DispatchQueue.main.async {
                self.isCameraAvailable = false
            }
        @unknown default:
            fatalError("Unknown audio authorization status")
        }
    }
    
    private func initializeSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .hd1920x1080
        
        fetchDevices()
        
        guard let videoDevice = selectedCamera,
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            print("Failed to initialize video device")
            return
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
            print("Video input added: \(videoDevice.localizedName)")
        } else {
            print("Failed to add video input")
            return
        }
        
        guard let audioDevice = selectedAudioDevice,
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {
            print("Failed to initialize audio device")
            return
        }
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
            print("Audio input added: \(audioDevice.localizedName)")
        } else {
            print("Failed to add audio input")
            return
        }
        
        setupAudioRecorder()
        
        let output = AVCaptureMovieFileOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            if let videoConnection = output.connection(with: .video) {
                if videoConnection.isVideoOrientationSupported {
                    videoConnection.videoOrientation = .portrait
                }
            }
        }
        
        // Set up preview layer off-thread
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        if let connection = preview.connection {
            if connection.isVideoMirroringSupported {
                connection.automaticallyAdjustsVideoMirroring = false
                connection.isVideoMirrored = true
                print("Preview mirroring set to: \(connection.isVideoMirrored)")
            }
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = .portrait
                print("Preview orientation set to portrait")
            }
        }
        preview.needsDisplayOnBoundsChange = true
        print("Preview layer created: \(preview), session: \(session)")
        
        // Update UI and start session on main thread
        DispatchQueue.main.async {
            self.movieOutput = output
            self.previewLayer = preview
            self.captureSession = session
            session.startRunning()
            self.isCameraAvailable = true
            print("Session started with new preview layer: \(preview)")
        }
    }
    
    func updateSession() {
        guard let session = captureSession else {
            print("No capture session to update")
            return
        }
        
        // Stop the session asynchronously
        DispatchQueue.global(qos: .userInitiated).async {
            session.stopRunning()
            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }
            
            // Clear old preview layer on main thread
            DispatchQueue.main.async {
                self.previewLayer?.removeFromSuperlayer()
                self.previewLayer = nil
                self.captureSession = nil
                self.movieOutput = nil
                print("Session and preview cleared")
            }
            
            // Reinitialize on background thread, then update UI
            self.initializeSession()
        }
    }
    
    func startRecording() {
        guard let movieOutput = movieOutput, !movieOutput.isRecording else { return }
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov") // Initial recording as MOV
        
        // Set up audio recorder for level monitoring
        setupAudioRecorder()
        
        movieOutput.startRecording(to: outputURL, recordingDelegate: self)
        isRecording = true
        
        // Start monitoring audio levels
        audioRecorder?.record()
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateAudioLevel()
        }
        
        timerCountdown = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            if(self != nil){
                self!.timeRemaining = self!.timeRemaining > 0 ? self!.timeRemaining - 1 : 0
                print("time remaining=\(self!.timeRemaining)")
                if self!.isRecording && self!.timeRemaining == 0 {
                    self!.stopRecording()
                }
            }
        }
    }
    
    func stopRecording() {
        movieOutput?.stopRecording()
        audioRecorder?.stop()
        levelTimer?.invalidate()
        timerCountdown?.invalidate()
        levelTimer = nil
        audioLevel = 0.0
        timeRemaining = maxDuration;
    }
    
    func setupAudioRecorder() {
        let audioURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("tempAudio.m4a")
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            print("Audio recorder set up successfully")
        } catch {
            print("Failed to set up audio recorder: \(error.localizedDescription)")
        }
    }
    
    private func updateAudioLevel() {
        audioRecorder?.updateMeters()
        let averagePower = audioRecorder?.averagePower(forChannel: 0) ?? -160.0
        // Convert dB to a 0-1 scale for visualization
        let normalizedLevel = max(0.0, (averagePower + 160.0) / 160.0) // Map -160 dB to 0 dB to 0-1
        DispatchQueue.main.async {
            self.audioLevel = normalizedLevel
        }
    }
    
    // Transcode the video to 1080x1920, ensuring proper centering and no mirroring
    private func transcodeVideo(from inputURL: URL, to outputURL: URL, completion: @escaping (Bool) -> Void) {
        let asset = AVAsset(url: inputURL)
        guard let videoTrack = asset.tracks(withMediaType: .video).first else {
            print("No video track found in asset")
            completion(false)
            return
        }
        
        // Check for audio tracks
        let audioTracks = asset.tracks(withMediaType: .audio)
        print("Number of audio tracks in initial video: \(audioTracks.count)")
        if let audioTrack = audioTracks.first {
            let formatDescriptions = audioTrack.formatDescriptions as! [CMFormatDescription]
            for desc in formatDescriptions {
                let audioFormat = CMAudioFormatDescriptionGetStreamBasicDescription(desc)?.pointee
                print("Audio format: sampleRate=\(audioFormat?.mSampleRate ?? 0), channels=\(audioFormat?.mChannelsPerFrame ?? 0), formatID=\(String(format: "%x", audioFormat?.mFormatID ?? 0))")
            }
            print("Audio duration: \(audioTrack.timeRange.duration.seconds) seconds")
        }
        print("Number of audio tracks in source asset: \(audioTracks.count)")
        
        // Use AVMutableComposition to explicitly include audio and video tracks
        let composition = AVMutableComposition()
        
        // Add video track
        if let videoTrack = asset.tracks(withMediaType: .video).first {
            let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? compositionVideoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)
        }
        
        // Add audio track
        if let audioTrack = asset.tracks(withMediaType: .audio).first {
            let compositionAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try? compositionAudioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: audioTrack, at: .zero)
        }
        
        guard let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
            print("Failed to create export session")
            completion(false)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        // Set up video composition for 1080x1920
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = CGSize(width: 1080, height: 1920)
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30) // 30 fps
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: asset.duration)
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        // Calculate the transform to scale and center the video
        var naturalSize = videoTrack.naturalSize
        var preferredTransform = videoTrack.preferredTransform
        print("Source video natural size: \(naturalSize), preferred transform: \(preferredTransform)")
        
        // Adjust natural size based on preferred transform (e.g., if rotated)
        if preferredTransform.a == 0 && preferredTransform.d == 0 {
            // 90 or 270 degrees rotation
            naturalSize = CGSize(width: naturalSize.height, height: naturalSize.width)
        }
        
        // Explicitly remove mirroring by applying a corrective transform
        let aspectRatio = naturalSize.width / naturalSize.height
        let targetAspectRatio: CGFloat = 1080.0 / 1920.0 // 9:16
        
        // Start with an identity transform and build from scratch
        var transform = CGAffineTransform.identity
        
        // Apply scaling to fill the 1080x1920 frame (mimicking resizeAspectFill)
        if aspectRatio > targetAspectRatio {
            let scale = 1920.0 / naturalSize.height  // Scale based on height (1920px)
            transform = CGAffineTransform(scaleX: scale, y: scale)
            let offsetX = 640.0
            transform = transform.translatedBy(x: -offsetX, y: 0)
        } else {
            // Source is taller than 9:16, scale to fit width and crop top/bottom
            let scale = 1080.0 / naturalSize.width
            transform = CGAffineTransform(scaleX: scale, y: scale)
            let scaledHeight = naturalSize.height * scale
            let offsetY = (scaledHeight - 1920.0) / 2.0
            transform = transform.translatedBy(x: 0, y: -offsetY)
        }
        
        transform = transform.scaledBy(x: -1, y: 1)
        transform = transform.translatedBy(x: -naturalSize.width, y: 0)
        transform = transform.concatenating(preferredTransform)
        
        // Debug the transform
        print("Final applied transform: scaleX=\(transform.a), scaleY=\(transform.d), translateX=\(transform.tx), translateY=\(transform.ty)")
        
        layerInstruction.setTransform(transform, at: .zero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        exportSession.videoComposition = videoComposition
        
        // Export
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                print("Transcoding completed: \(outputURL.path)")
                // Check for audio tracks in the final video
                let finalAsset = AVAsset(url: outputURL)
                let finalAudioTracks = finalAsset.tracks(withMediaType: .audio)
                print("Number of audio tracks in final asset: \(finalAudioTracks.count)")
                completion(true)
            case .failed:
                print("Transcoding failed: \(exportSession.error?.localizedDescription ?? "Unknown error")")
                completion(false)
            case .cancelled:
                print("Transcoding cancelled")
                completion(false)
            default:
                break
            }
        }
    }
}

extension VideoRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        DispatchQueue.main.async {
            self.isRecording = false
            self.isSaving = true;
            if let error = error {
                print("Recording failed: \(error.localizedDescription)")
            } else {
                print("Initial video saved at: \(outputFileURL.path)")
                // Check for audio tracks in the initial video
                let asset = AVAsset(url: outputFileURL)
                let audioTracks = asset.tracks(withMediaType: .audio)
                print("Number of audio tracks in initial video: \(audioTracks.count)")
                for audioTrack in audioTracks {
                    print(audioTrack.asset)
                }
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let finalURL = documentsURL.appendingPathComponent("InstaStory_\(Date().timeIntervalSince1970).mp4")
                
                // Transcode to 1080x1920
                self.transcodeVideo(from: outputFileURL, to: finalURL) { success in
                    if success {
                        // Clean up temporary file
                        //try? FileManager.default.removeItem(at: outputFileURL)
                        DispatchQueue.main.async{
                            self.showSavePanel(for: finalURL)
                        }
                    } else {
                        print("Failed to transcode video")
                        DispatchQueue.main.async{
                            self.isSaving = false;
                        }
                    }
                    
                }
            }
        }
    }
    
    func showSavePanel(for outputFileURL: URL) {
        self.isSaving = false;
        let savePanel = NSSavePanel()
        savePanel.allowedFileTypes = ["mp4"]
        savePanel.nameFieldStringValue = "InstaStory_\(Int(Date().timeIntervalSince1970)).mp4"
        
        savePanel.begin { response in
            if response == .OK, let destinationURL = savePanel.url {
                do {
                    try FileManager.default.moveItem(at: outputFileURL, to: destinationURL)
                    print("Final video saved at: \(destinationURL.path)")
                } catch {
                    print("Failed to move file: \(error.localizedDescription)")
                }
            } else {
                print("User canceled file save.")
            }
            try? FileManager.default.removeItem(at: outputFileURL)
        }
    }
}

