//
//  ExerciseRow.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI

struct ExerciseRow: View {
    let exercise: Exercise
    let userProfile: UserProfile
    let dayName: String
    var connectedUp: Bool = false
    var connectedDown: Bool = false
    var showSeparator: Bool = true
    var isSessionView: Bool
    var historicalWorkout: CompletedWorkout? = nil
    var isEditing: Bool = false
    
    // NEW: Property to know if the workout is marked as done
    var isDayComplete: Bool = false
    
    @EnvironmentObject var database: ExerciseDatabase
    @EnvironmentObject var workoutManager: WorkoutManager
    
    // MARK: - Adaptive Metrics
    // Base size 40, scales with Dynamic Type
    @ScaledMetric var boxSize: CGFloat = 40
    // Base font size 8, scales with Dynamic Type
    @ScaledMetric var setsLabelSize: CGFloat = 8
    
    var completedSets: Int {
        if let session = workoutManager.currentSession {
            if let loggedExercise = session.exercises.first(where: { $0.name == exercise.name }) {
                return loggedExercise.sets.count
            }
        }
        if let history = historicalWorkout {
            if let loggedExercise = history.exercises.first(where: { $0.name == exercise.name }) {
                return loggedExercise.sets.count
            }
        }
        return 0
    }
    
    var currentWeightValue: Double? {
        if exercise.equipment == .bodyweight { return nil }
        if let manualWeight = database.getWeight(for: exercise.name) {
            return manualWeight
        }
        if let target = exercise.targetWeight(userProfile: userProfile) {
            return target
        }
        return nil
    }
    
    var displayWeight: String {
        guard let weight = currentWeightValue else { return "-" }
        return weight.formattedWeight
    }
    
    var previousWeightValue: Double? {
        let previousWorkout = workoutManager.history.last { $0.dayName == dayName }
        guard let exerciseLog = previousWorkout?.exercises.first(where: { $0.name == exercise.name }) else { return nil }
        return exerciseLog.sets.last?.weight
    }
    
    var isWeightIncreased: Bool {
        guard let current = currentWeightValue, let previous = previousWeightValue else { return false }
        return current > previous + 0.01
    }
    
    var displayReps: String {
        return workoutManager.getReps(for: exercise.name, defaultReps: exercise.reps)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                if connectedUp || connectedDown {
                    VStack(spacing: 0) {
                        if connectedUp {
                            Rectangle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        } else {
                            Color.clear
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                        
                        Image(systemName: "link")
                            .font(.system(size: 10))
                            .foregroundColor(.gray.opacity(0.8))
                            .frame(width: 14, height: 14)
                            .background(Color.clear)
                        
                        if connectedDown {
                            Rectangle()
                                .fill(Color.gray.opacity(0.6))
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        } else {
                            Color.clear
                                .frame(width: 2)
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 16)
                }
                
                VStack {
                    if completedSets >= exercise.sets {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    } else if isDayComplete {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.red)
                    } else {
                        if completedSets > 0 {
                            Text("\(completedSets)/\(exercise.sets)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .minimumScaleFactor(0.5)
                        } else {
                            Text("\(exercise.sets)")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        Text("SETS")
                            .font(.system(size: setsLabelSize, weight: .black)) // ADAPTIVE
                            .foregroundColor(.primary.opacity(0.7))
                    }
                }
                .frame(width: boxSize, height: boxSize) // ADAPTIVE
                .padding(4)
                .background(Color.green.opacity(0.15))
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack {
                        if exercise.equipment != .bodyweight {
                            if displayWeight != "-" {
                                HStack(spacing: 6) {
                                    Text("\(displayWeight) lbs")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.gray)
                                    
                                    if isWeightIncreased {
                                        ZStack {
                                            Circle().fill(Color.green)
                                            Image(systemName: "arrow.up")
                                                .font(.caption2.weight(.bold))
                                                .foregroundColor(.white)
                                        }
                                        .frame(width: 16, height: 16)
                                        .accessibilityLabel("Weight increased")
                                    }
                                }
                                
                                Text("•")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        if displayReps.contains(":") {
                            Text("\(displayReps) seconds")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                            Text("\(displayReps) Reps")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Spacer()
                
                if !isEditing && (isSessionView || historicalWorkout != nil) {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .transition(.opacity)
                }
            }
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
            
            if showSeparator {
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
        }
    }
}
