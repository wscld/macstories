//
//  RecorderActionsView.swift
//  MacStories
//
//  Created by Wesley Caldas on 26/03/25.
//
import SwiftUICore
import SwiftUI

struct RecorderView: View{
    @ObservedObject var recorder: VideoRecorder
    
    var body: some View {
        HStack(spacing: 20) {
            Button {
                if recorder.isRecording {
                    recorder.stopRecording()
                } else {
                    recorder.startRecording()
                }
            } label:{
                Circle().frame(width: 40, height: 40, alignment: .center).background{
                    if(recorder.isRecording){
                        Color.white
                            .cornerRadius(20)
                    }else{
                        Color.red
                            .cornerRadius(20)
                    }
                }
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.black.opacity(0))
            .frame(width: 60,height: 60)
            .clipShape(.circle)
            .background {
                if(recorder.isRecording){
                    Color.red
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 0.5)
                                .stroke(.white, lineWidth: 1)
                        )
                }else{
                    Color.white
                        .cornerRadius(50)
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .inset(by: 0.5)
                                .stroke(.black.opacity(0.3), lineWidth: 1)
                        )
                }
            }.disabled(!recorder.isCameraAvailable || recorder.isSaving)
            Spacer()
            if(recorder.isSaving){
                Text("Saving...")
                    .padding()
                    .foregroundColor(.red)
            }else{
                Text(recorder.isRecording ? "Recording..." : "Ready")
                    .padding()
                    .foregroundColor(recorder.isRecording ? .red : .black)
            }
        }
    }
}
