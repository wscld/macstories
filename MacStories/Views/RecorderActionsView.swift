//
//  RecorderActionsView.swift
//  MacStories
//
//  Created by Wesley Caldas on 26/03/25.
//
import SwiftUICore
import SwiftUI

struct RecorderView: View {
    @ObservedObject var recorder: VideoRecorder

    var body: some View {
        HStack(spacing: 20) {
            Button {
                if recorder.isRecording {
                    recorder.stopRecording()
                } else {
                    recorder.startRecording()
                }
            } label: {
                Circle()
                    .frame(width: 40, height: 40, alignment: .center)
                    .background {
                        if recorder.isRecording {
                            Color.white.cornerRadius(20)
                        } else {
                            Color.red.cornerRadius(20)
                        }
                    }
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.black.opacity(0))
            .frame(width: 60, height: 60)
            .clipShape(.circle)
            .animation(.easeInOut(duration: 0.3), value: recorder.isRecording)
            .background {
                if recorder.isRecording {
                    Color.red
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 0.5)
                                .stroke(.white, lineWidth: 1)
                        )
                } else {
                    Color.white
                        .cornerRadius(50)
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 0.5)
                                .stroke(.black.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .disabled(!recorder.isCameraAvailable || recorder.isSaving)

            Spacer()

            ZStack(alignment: .leading) {
                let maxWidth: CGFloat = 180
                let percentage = CGFloat((recorder.timeRemaining * Int(maxWidth)) / 60)
                let safeWidth = max(percentage, 15) // Evita que fique muito fina

                // Gradiente de cor suave
                let progressColor = Color(
                    red: (1.0 - (safeWidth / maxWidth)) * 1.2,
                    green: (safeWidth / maxWidth) * 0.8,
                    blue: 0.0
                )

                Capsule()
                    .fill(recorder.isSaving ? Color.red :
                            recorder.isRecording ? Color.green.opacity(0.3) : Color.white.opacity(0.6))
                    .frame(width: maxWidth, height: 35)
                    .overlay(
                        ZStack(alignment: .center) {
                            if recorder.isRecording {
                                Capsule()
                                    .fill(progressColor)
                                    .frame(width: safeWidth, height: 35)
                                    .animation(.easeInOut(duration: 1), value: percentage)
                            }
                            Text(recorder.isSaving ? "Saving..." : recorder.isRecording ? "Recording..." : "Ready to record")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(recorder.isSaving ? .white : .black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                        }
                    )
                    .clipShape(Capsule()) // Garante que a barra de progresso fique dentro
                    .shadow(color: recorder.isRecording ? Color.green.opacity(0.6) : Color.clear, radius: 6)
            }
            .frame(height: 35)
        }
    }
}
