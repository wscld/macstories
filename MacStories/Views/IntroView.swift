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
    @State private var featureRowsVisible: [Bool] = [false, false, false, false]
    @State private var footerOpacity: Double = 0.0 // Added for footer animation
    @State private var backgroundColor: Color = .clear

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Image("macstories")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .clipped()
                .padding(.top, 20) // Added padding to balance spacing

            Text("MacStories")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .opacity(titleOpacity)
                .offset(y: titleOffset)
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        titleOpacity = 1.0
                        titleOffset = 0
                    }
                }

            Text("Thank you for purchasing MacStories!")
                .font(.system(size: 18, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
                .padding(.bottom, 20)
                .opacity(titleOpacity)
                .offset(y: titleOffset)

            // Feature List with staggered animation
            ForEach(0..<4) { index in
                FeatureRow(title: featureTitles[index])
                    .opacity(featureRowsVisible[index] ? 1.0 : 0.0)
                    .offset(x: featureRowsVisible[index] ? 0 : -50)
                    .onAppear {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(index) * 0.15)) {
                            featureRowsVisible[index] = true
                        }
                    }
            }

            Spacer() // Pushes footer to the bottom

            // Footer with attribution and support link
            VStack(spacing: 5) {
                Text("Built by Wesley Caldas")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))

                Link("Get Support", destination: URL(string: "https://wscld.co")!)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.blue)
                    .underline()
            }
            .opacity(footerOpacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).delay(0.6)) { // Delayed to appear after features
                    footerOpacity = 1.0
                }
            }
            .padding(.bottom, 20) // Space from bottom edge
        }
        .frame(width: 650, height: 500)
        .background(backgroundColor)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                backgroundColor = .black
            }
        }
    }

    // Feature titles array
    private let featureTitles = [
        "Content Creation for Social Media",
        "Personal Vlogs or Memories",
        "Creative Video Projects",
        "Educational Recordings",
    ]
}

// Reusable Feature Row View with Floating Effect
struct FeatureRow: View {
    let title: String
    @State private var isHovered: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.2))
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .offset(y: isHovered ? -2 : 0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .padding(.horizontal, 10)
    }
}

// Preview
struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}
