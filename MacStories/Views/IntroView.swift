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
            // Left Panel: Features List
            VStack(alignment: .leading, spacing: 10) {
                Text("MacStories")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.leading, 20)
                    .opacity(titleOpacity)
                    .offset(x: titleOffset)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            titleOpacity = 1.0
                            titleOffset = 0
                        }
                    }
                
                Spacer()
                
                Text("Great for")
                    .font(.system(size: 18, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.white)
                    .padding(.leading, 10)
                
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
            .frame(width: 300)
            .background(backgroundColor)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0)) {
                    backgroundColor = .black
                }
            }
            
            // Right Panel: Call to Action
            VStack(alignment: .center, spacing: 20) {
                Spacer()
                Text("Thank you for \n purchasing MacStories")
                    .font(.system(size: 18, weight: .bold))
                    .multilineTextAlignment(.center)
                    .scaleEffect(ctaScale)
                    .opacity(ctaOpacity)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.0)) {
                            ctaScale = 1.0
                            ctaOpacity = 1.0
                        }
                    }
                Spacer()
            }
            .frame(width: 350)
            .background(Color.white)
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
        .padding(.vertical, 5)
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
