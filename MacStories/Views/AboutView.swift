//
//  AboutView.swift
//  MacStories
//
//  Created by Wesley Caldas on 26/03/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("MacStories")
                .font(.largeTitle)
                .bold()
            
            Text("Version 1.0.0")
                .foregroundColor(.gray)
            
            Text("Created by Wesley Caldas")
                .font(.headline)
            
            Button("Close") {
                NSApplication.shared.keyWindow?.close()
            }
            .padding(.top, 10)
        }
        .frame(width: 300, height: 200)
        .padding()
    }
}
