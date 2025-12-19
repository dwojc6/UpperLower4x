//
//  AddExerciseToDaySheet.swift
//  Upper Lower
//
//  Created by David Wojcik III on 12/1/25.
//

import SwiftUI

struct AddExerciseToDaySheet: View {
    // UPDATED: Now requires the full day object to scope to the week
    let day: WorkoutDay
    
    @EnvironmentObject var database: ExerciseDatabase
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var selectedExercise: String?
    @State private var repsInput = "10"
    @State private var setsInput = "3"
    @State private var selectedEquipment: Equipment = .machine
    @State private var showConfig = false
    
    var filteredExercises: [String] {
        if searchText.isEmpty {
            return database.allExerciseNames
        } else {
            return database.allExerciseNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search...", text: $searchText)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding()
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filteredExercises, id: \.self) { name in
                                Button(action: {
                                    selectedExercise = name
                                    showConfig = true
                                }) {
                                    HStack {
                                        Text(name)
                                            .foregroundColor(.white)
                                            .padding()
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.green)
                                            .padding()
                                    }
                                }
                                Divider().background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showConfig) {
                NavigationView {
                    Form {
                        Section(header: Text("Details")) {
                            HStack {
                                Text("Sets")
                                Spacer()
                                TextField("Sets", text: $setsInput)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                            }
                            HStack {
                                Text("Reps")
                                Spacer()
                                TextField("Reps", text: $repsInput)
                                    .keyboardType(.asciiCapable)
                                    .multilineTextAlignment(.trailing)
                            }
                        }
                        
                        Section(header: Text("Equipment")) {
                            Picker("Type", selection: $selectedEquipment) {
                                ForEach(Equipment.allCases, id: \.self) { eq in
                                    Text(eq.rawValue).tag(eq)
                                }
                            }
                        }
                    }
                    .navigationTitle(selectedExercise ?? "Configuration")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { showConfig = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                addExercise()
                                showConfig = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    func addExercise() {
        guard let name = selectedExercise else { return }
        
        let newExercise = Exercise(
            name: name,
            sets: Int(setsInput) ?? 3,
            reps: repsInput,
            liftType: .accessory,
            percentageOf1RM: nil,
            rpeOrNotes: "Custom Added",
            equipment: selectedEquipment
        )
        
        // UPDATED: Pass the day object
        workoutManager.addExerciseToSchedule(day: day, exercise: newExercise)
        dismiss()
    }
}
