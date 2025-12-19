//
//  SessionTimerButton.swift
//  Upper Lower
//
//  Created by David Wojcik III on 12/2/25.
//

import SwiftUI

struct SessionTimerButton: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    var body: some View {
        Button(action: { workoutManager.togglePause() }) {
            HStack(spacing: 4) {
                Image(systemName: workoutManager.isTimerPaused ? "pause.circle.fill" : "timer")
                    .foregroundColor(workoutManager.isTimerPaused ? .yellow : .green)
                Text(workoutManager.formattedTime)
                    .font(.system(.body, design: .monospaced)).fontWeight(.bold)
                    .foregroundColor(workoutManager.isTimerPaused ? .yellow : .green)
            }
        }
    }
}
