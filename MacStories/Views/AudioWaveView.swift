//
//  AudioWaveView.swift
//  MacStories
//
//  Created by Wesley Caldas on 25/03/25.
//

import SwiftUICore

struct AudioWaveView: View {
    @ObservedObject var recorder: VideoRecorder
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let amplitude = height * CGFloat(recorder.audioLevel)
            
            Path { path in
                let midY = height / 2
                path.move(to: CGPoint(x: 0, y: midY))
                path.addLine(to: CGPoint(x: width, y: midY))
                
                // Simple wave effect based on audio level
                for x in stride(from: 0, to: width, by: 2) {
                    let normalizedX = x / width
                    let wave = sin(normalizedX * 10 * .pi) * amplitude
                    path.move(to: CGPoint(x: x, y: midY))
                    path.addLine(to: CGPoint(x: x, y: midY + wave))
                }
            }
            .stroke(Color.red, lineWidth: 1)
        }
        .frame(height: 50)
        .background(Color.black.opacity(0))
    }
}
