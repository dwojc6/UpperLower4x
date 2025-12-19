//
//  ExerciseMenuButton.swift
//  Upper Lower
//
//  Created by David Wojcik III on 12/2/25.
//


import SwiftUI

struct ExerciseMenuButton: View {
    let exercises: [Exercise]
    let database: ExerciseDatabase
    let workoutManager: WorkoutManager // Passed as plain reference, NOT ObservedObject
    
    @State private var exerciseToEdit: Exercise?
    @State private var showEditWeightAlert = false
    @State private var showEditRepsAlert = false
    @State private var editWeightInput = ""
    @State private var editRepsInput = ""
    
    var body: some View {
        Menu {
            ForEach(exercises) { exercise in
                if exercises.count > 1 {
                    Text(exercise.name).font(.caption).foregroundColor(.gray)
                }
                
                Button {
                    exerciseToEdit = exercise
                    editWeightInput = "\(Int(database.getWeight(for: exercise.name) ?? 0))"
                    showEditWeightAlert = true
                } label: {
                    Label("Change Weight", systemImage: "scalemass")
                }
                
                Button {
                    exerciseToEdit = exercise
                    // Use the reference to fetch data, but this doesn't create a view dependency on the timer
                    editRepsInput = workoutManager.getReps(for: exercise.name, defaultReps: exercise.reps)
                    showEditRepsAlert = true
                } label: {
                    Label("Change Reps", systemImage: "arrow.triangle.2.circlepath")
                }
                
                // CHECK if equipment is barbell-related before showing menu
                if [.barbell, .barbell25, .smithMachine].contains(exercise.equipment) {
                    Menu {
                        Button("45 lbs (Standard)") {
                            workoutManager.updateEquipment(for: exercise.name, to: .barbell)
                        }
                        Button("25 lbs (Preacher)") {
                            workoutManager.updateEquipment(for: exercise.name, to: .barbell25)
                        }
                        Button("15 lbs (Smith)") {
                            workoutManager.updateEquipment(for: exercise.name, to: .smithMachine)
                        }
                    } label: {
                        Label("Barbell Weight", systemImage: "dumbbell.fill")
                    }
                }
                
                if exercises.count > 1 {
                    Divider()
                }
            }
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .alert("Change Weight", isPresented: $showEditWeightAlert) {
            TextField("Weight", text: $editWeightInput).keyboardType(.decimalPad)
            Button("Save") {
                if let ex = exerciseToEdit, let w = Double(editWeightInput) {
                    database.saveWeight(for: ex.name, weight: w)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Change Reps", isPresented: $showEditRepsAlert) {
            TextField("Reps", text: $editRepsInput)
            Button("Save") {
                if let ex = exerciseToEdit {
                    workoutManager.updateReps(for: ex.name, reps: editRepsInput)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
