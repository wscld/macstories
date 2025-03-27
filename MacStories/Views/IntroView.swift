//
//  IntroView.swift
//  MacStories
//
//  Created by Wesley Caldas on 27/03/25.
//

import SwiftUI

struct IntroView: View {
    // State for controlling animations
    @State private var titleOpacity: Double = 0.0
    @State private var titleOffset: CGFloat = -50
    @State private var featureRowsVisible: [Bool] = [false, false, false, false, false]
    @State private var ctaScale: CGFloat = 0.5
    @State private var ctaOpacity: Double = 0.0
    @State private var backgroundColor: Color = .clear

    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .center, spacing: 10) {
                
                Image("macstories")
                    .resizable()
                    .cornerRadius(16)
                    .scaledToFit()
                    .padding(.top, 20)
                    .frame(width: 60, height: 60)
                    .clipped()
                
                Text("MacStories")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .opacity(titleOpacity)
                    .offset(x: titleOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            titleOpacity = 1.0
                            titleOffset = 0
                        }
                    }
                
                Spacer()
                
                Text("Thank you for purchasing MacStories")
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .padding(.bottom, 20)
                
                // Feature List with staggered animation
                ForEach(0..<4) { index in
                    FeatureRow(title: featureTitles[index])
                        .opacity(featureRowsVisible[index] ? 1.0 : 0.0)
                        .offset(x: featureRowsVisible[index] ? 0 : -50)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 0.5).delay(Double(index) * 0.2)) {
                                featureRowsVisible[index] = true
                            }
                        }
                }
                
                Spacer()
            }
            .frame(width: 650)
            .background(backgroundColor)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    backgroundColor = .black
                }
            }
        }
        .frame(width: 650, height: 400)
        .background(Color.gray.opacity(0.1))
    }
    
    // Feature titles array for easy access
    private let featureTitles = [
        "Content Creation for Social Media",
        "Personal Vlogs or Memories",
        "Creative Video Projects",
        "Educational Recordings",
    ]
}

// Reusable Feature Row View
struct FeatureRow: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.2))
        .cornerRadius(8)
        .padding(.horizontal, 10)
    }
}

// Preview
struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
