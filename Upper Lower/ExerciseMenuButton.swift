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
    let barbellBaseWeights: [String: Double]
    var onEditNote: ((Exercise) -> Void)? = nil
    
    // MARK: - Equatable Implementation
    // This is the CRITICAL fix. It prevents the view from redrawing (and closing the menu)
    // every time the WorkoutManager timer ticks (1s), unless the actual exercises list changes.
    static func == (lhs: ExerciseMenuButton, rhs: ExerciseMenuButton) -> Bool {
        // We only redraw if the exercises array changes.
        // We ignore onEditNote and managers since they are stable references/closures.
        return lhs.exercises == rhs.exercises && lhs.barbellBaseWeights == rhs.barbellBaseWeights
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

                    Menu {
                        ForEach(Equipment.allCases, id: \.self) { equipment in
                            Button {
                                workoutManager.updateEquipment(for: exercise.name, to: equipment)
                            } label: {
                                if exercise.equipment == equipment {
                                    Label(equipment.rawValue, systemImage: "checkmark")
                                } else {
                                    Label(equipment.rawValue, systemImage: equipment.iconName)
                                }
                            }
                        }
                    } label: {
                        Label("Change Equipment", systemImage: "wrench.and.screwdriver")
                    }
                    .id("equipment-menu-\(exercise.id)")

                    if exercise.equipment == .barbell {
                        let currentBase = workoutManager.getBarbellBaseWeight(for: exercise.name, defaultWeight: exercise.equipment.baseWeight)
                        Menu {
                            Button {
                                workoutManager.updateBarbellBaseWeight(for: exercise.name, to: 45)
                            } label: {
                                if currentBase == 45 {
                                    Label("45 lbs (Standard)", systemImage: "checkmark")
                                } else {
                                    Label("45 lbs (Standard)", systemImage: "scalemass.fill")
                                }
                            }
                            Button {
                                workoutManager.updateBarbellBaseWeight(for: exercise.name, to: 25)
                            } label: {
                                if currentBase == 25 {
                                    Label("25 lbs (Preacher)", systemImage: "checkmark")
                                } else {
                                    Label("25 lbs (Preacher)", systemImage: "scalemass.fill")
                                }
                            }
                            Button {
                                workoutManager.updateBarbellBaseWeight(for: exercise.name, to: 15)
                            } label: {
                                if currentBase == 15 {
                                    Label("15 lbs (Smith)", systemImage: "checkmark")
                                } else {
                                    Label("15 lbs (Smith)", systemImage: "scalemass.fill")
                                }
                            }
                        } label: {
                            Label("Barbell Weight", systemImage: "scalemass")
                        }
                        .id("barbell-weight-\(exercise.id)")
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
