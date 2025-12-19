//
//  ExerciseSetRow.swift
//  Upper Lower
//
//  Created by David Wojcik III on 12/1/25.
//

import SwiftUI

struct ExerciseSetRow: View {
    let exercise: Exercise
    let setIndex: Int
    let weight: Double
    let reps: String
    let completedReps: Int?
    var showExerciseName: Bool = false
    let isSessionView: Bool
    let onTap: () -> Void
    
    // MARK: - Adaptive Metrics
    @ScaledMetric var circleSize: CGFloat = 40
    @ScaledMetric var rowPadding: CGFloat = 10
    
    var targetRepCount: Int {
        let cleanString = reps.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Int(cleanString) ?? 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                if showExerciseName {
                    Text(exercise.name.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                }
                Text("SET \(setIndex + 1)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                HStack(alignment: .bottom, spacing: 2) {
                    // Hide weight display for bodyweight
                    if exercise.equipment != .bodyweight {
                        Text("\(Int(weight))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Text("lbs")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 1)
                        Text("x")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 1)
                    }
                    
                    Text(reps)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if reps.contains(":") {
                        Text("seconds")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 1)
                    } else {
                        Text("reps")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.bottom, 1)
                    }
                }
                
                if let plates = exercise.equipment.getPlateBreakdown(for: weight) {
                    HStack(spacing: 4) {
                        Image(systemName: "circle.circle")
                        Text(plates)
                    }
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                    .padding(.top, 2)
                }
            }
            Spacer()
            
            if isSessionView {
                Button(action: onTap) {
                    ZStack {
                        if let completedReps = completedReps {
                            let isTargetMet = completedReps >= targetRepCount
                            let opacity = isTargetMet ? 1.0 : 0.4
                            
                            Circle()
                                .fill(Color.green.opacity(opacity))
                                .frame(width: circleSize, height: circleSize)
                            
                            if reps.contains(":") {
                                Image(systemName: "checkmark")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(isTargetMet ? .black : .white)
                            } else {
                                Text("\(completedReps)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(isTargetMet ? .black : .white)
                            }
                                
                        } else {
                            Circle()
                                .stroke(Color.gray, lineWidth: 2)
                                .frame(width: circleSize, height: circleSize)
                            
                            Text(reps.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
        .padding(rowPadding)
        .background(Color(UIColor.systemGray6).opacity(0.3))
        .cornerRadius(12)
    }
}
