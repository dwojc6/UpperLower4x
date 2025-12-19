//
//  CompactTimerView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI

struct CompactTimerView: View {
    @Binding var timeRemaining: Int
    var isPaused: Bool
    var onAdd: () -> Void
    var onSkip: () -> Void
    var onPause: () -> Void
    
    @ScaledMetric var circleSize: CGFloat = 40
    @ScaledMetric var iconSize: CGFloat = 14
    
    var body: some View {
        HStack(spacing: 15) {
            Button(action: onPause) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .stroke(isPaused ? Color.yellow : Color.green.opacity(0.3), lineWidth: 3)
                            .frame(width: circleSize, height: circleSize)
                        Image(systemName: isPaused ? "pause.fill" : "clock.fill")
                            .foregroundColor(isPaused ? .yellow : .green)
                            .font(.system(size: iconSize))
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text(isPaused ? "PAUSED" : "REST TIMER")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        Text(timeString(time: timeRemaining))
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(isPaused ? .yellow : .white)
                    }
                }
            }
            Spacer()
            HStack(spacing: 10) {
                Button(action: onAdd) {
                    Text("+30s")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                Button(action: onSkip) {
                    Image(systemName: "xmark")
                        .font(.body)
                        .padding(10)
                        .background(Color.red.opacity(0.2))
                        .foregroundColor(.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.1), lineWidth: 1))
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
