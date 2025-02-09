//
//  ContentView.swift
//  HeartLogger Watch App
//
//  Created by Simone Boscaglia on 07/02/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var monitor = HeartRateMonitor()
    @State private var animationAmount = 1.0

    var body: some View {
        VStack {
            Image(systemName: "heart.fill")
                .font(.system(size: 25))
                .foregroundStyle(.tint)
                .scaleEffect(animationAmount)
                .animation(
                    .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animationAmount
                )
            Text("Your heart rate:")
                .padding()
                .fontWeight(.bold)
            if monitor.heartRate != nil {
                Text("\(monitor.heartRate ?? -1) BPM")
                    .font(.system(size: animationAmount*10))
                    .animation(.default)
            } else {
                Text("Not detected.")
                    .font(.system(size: animationAmount*10))
            }
        }
        .padding()
        .onAppear() {
            animationAmount = 1.5
            monitor.requestAuthorization()
            monitor.startWorkout()
        }
    }
}

#Preview {
    ContentView()
}
