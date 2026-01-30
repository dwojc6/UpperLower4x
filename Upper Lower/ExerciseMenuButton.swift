//
//  ExerciseMenuButton.swift
//  Upper Lower
//
//  Created by David Wojcik III on 12/2/25.
//

import SwiftUI

struct ExerciseMenuButton: View, Equatable {
    let exercises: [Exercise]
    let database: ExerciseDatabase
    let workoutManager: WorkoutManager
    var onEditNote: ((Exercise) -> Void)? = nil
    
    // MARK: - Equatable Implementation
    // This is the CRITICAL fix. It prevents the view from redrawing (and closing the menu)
    // every time the WorkoutManager timer ticks (1s), unless the actual exercises list changes.
    static func == (lhs: ExerciseMenuButton, rhs: ExerciseMenuButton) -> Bool {
        // We only redraw if the exercises array changes.
        // We ignore onEditNote and managers since they are stable references/closures.
        return lhs.exercises == rhs.exercises
    }
    
    @State private var exerciseToEdit: Exercise?
    @State private var showEditWeightAlert = false
    @State private var showEditRepsAlert = false
    @State private var editWeightInput = ""
    @State private var editRepsInput = ""
    
    var body: some View {
        Menu {
            ForEach(exercises) { exercise in
                // Using Section gives each item a stable structural identity in the Menu
                Section {
                    Button {
                        exerciseToEdit = exercise
                        if let w = database.getWeight(for: exercise.name) {
                            editWeightInput = w.formattedWeight
                        } else {
                            editWeightInput = "0"
                        }
                        showEditWeightAlert = true
                    } label: {
                        Label("Change Weight", systemImage: "scalemass")
                    }
                    
                    Button {
                        exerciseToEdit = exercise
                        editRepsInput = workoutManager.getReps(for: exercise.name, defaultReps: exercise.reps)
                        showEditRepsAlert = true
                    } label: {
                        Label("Change Reps", systemImage: "arrow.triangle.2.circlepath")
                    }
                    
                    // Barbell Weight Nested Menu
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
                        // Unique ID ensures the menu doesn't conflict with others in the superset
                        .id("barbell-menu-\(exercise.id)")
                    }

                    if let onEditNote = onEditNote {
                        Button {
                            onEditNote(exercise)
                        } label: {
                            Label("Edit Note", systemImage: "pencil.and.list.clipboard")
                        }
                    }
                } header: {
                    // Header creates a clear visual separator for supersets
                    if exercises.count > 1 {
                        Text(exercise.name)
                    }
                }
            }
        } label: {
            Image(systemName: "pencil")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.green)
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
