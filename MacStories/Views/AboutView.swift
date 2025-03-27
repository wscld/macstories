//
//  AboutView.swift
//  MacStories
//
//  Created by Wesley Caldas on 26/03/25.
//

import SwiftUI
import AppKit

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("macstories")
                .resizable()
                .cornerRadius(16)
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipped()
            Text("MacStories")
                .font(.largeTitle)
                .bold()
            
            Text("Version 1.0.0")
                .foregroundColor(.gray)
                        
            Text("Created by Wesley Caldas")
                .font(.headline)
                .padding(.top, 20)
        }
        .frame(width: 300, height: 300)
        .padding()
    }
}

