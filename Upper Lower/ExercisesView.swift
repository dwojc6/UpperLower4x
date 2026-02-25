//
//  ExercisesView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var database: ExerciseDatabase
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var searchText = ""
    @State private var showAddAlert = false
    @State private var newExerciseName = ""
    @State private var newExerciseWeight = ""
    @State private var showDeleteAlert = false
    @State private var deleteTargetName: String?
    
    var filteredExercises: [String] {
        if searchText.isEmpty {
            return database.allExerciseNames
        } else {
            return database.allExerciseNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search exercises...", text: $searchText)
                        .foregroundColor(.white)
                        .accentColor(.green)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredExercises, id: \.self) { name in
                            ExerciseDatabaseRow(name: name)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        deleteTargetName = name
                                        showDeleteAlert = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding(.bottom, 20)
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .navigationTitle("Exercises")
        .background(Color(UIColor.systemBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    newExerciseName = ""
                    newExerciseWeight = ""
                    showAddAlert = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.green)
                }
            }
        }
        .alert("New Exercise", isPresented: $showAddAlert) {
            TextField("Exercise Name", text: $newExerciseName)
            TextField("Weight (Optional)", text: $newExerciseWeight)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                if !newExerciseName.isEmpty {
                    database.addCustomExercise(name: newExerciseName)
                    if let weight = Double(newExerciseWeight) {
                        database.saveWeight(for: newExerciseName, weight: weight)
                    }
                }
            }
        } message: {
            Text("Create a new exercise to track.")
        }
        .alert("Delete Exercise?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let name = deleteTargetName {
                    if database.customExercises.contains(name) {
                        database.removeCustomExercise(name: name)
                    } else {
                        database.hideExercise(name: name)
                    }
                    database.clearWeight(for: name)
                    workoutManager.clearOverrides(for: name)
                }
                deleteTargetName = nil
            }
            Button("Cancel", role: .cancel) {
                deleteTargetName = nil
            }
        } message: {
            Text("This will remove the custom exercise from your list.")
        }
    }
}

struct ExerciseDatabaseRow: View {
    let name: String
    @EnvironmentObject var database: ExerciseDatabase
    @State private var weightInput: String = ""
    @FocusState private var isFocused: Bool
    
    @ScaledMetric var inputWidth: CGFloat = 60
    
    var savedWeight: Double? {
        database.getWeight(for: name)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                NavigationLink(destination: ExerciseSettingsView(name: name)) {
                    HStack(spacing: 6) {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Input Field
                HStack(spacing: 5) {
                    TextField("0", text: $weightInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.primary)
                        .frame(width: inputWidth)
                        .focused($isFocused)
                        .onChange(of: isFocused) {
                            if !isFocused {
                                save()
                            }
                        }
                        .onSubmit {
                            save()
                        }
                    
                    Text("lbs")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color.primary.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
                .background(Color.secondary.opacity(0.3))
        }
        .onAppear {
            if let weight = savedWeight {
                // CHANGED: Use .formattedWeight so "12.5" doesn't become "12" in the text box
                weightInput = weight.formattedWeight
            }
        }
        .onChange(of: savedWeight) { _, newValue in
            if let weight = newValue {
                weightInput = weight.formattedWeight
            } else {
                weightInput = ""
            }
        }
    }
    
    func save() {
        if let value = Double(weightInput) {
            database.saveWeight(for: name, weight: value)
        }
    }
}

struct ExerciseSettingsView: View {
    let name: String
    
    @EnvironmentObject var database: ExerciseDatabase
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State private var selectedEquipment: Equipment = .machine
    @State private var barbellBaseWeight: Double = 45
    @State private var restTimerDurationSeconds: Int = 90
    @State private var didInitializeRestTimer = false
    @State private var showWeightAlert = false
    @State private var showProgressionAlert = false
    @State private var weightInput = ""
    @State private var progressionInput = ""
    
    var defaultProgramExercise: Exercise? {
        for week in 1...9 {
            let days = ProgramData.shared.getDays(forWeek: week)
            if let match = days.flatMap({ $0.exercises }).first(where: { $0.name == name }) {
                return match
            }
        }
        return nil
    }

    var defaultEquipment: Equipment {
        defaultProgramExercise?.equipment ?? .machine
    }

    var settingsExercise: Exercise {
        if let fromProgram = defaultProgramExercise {
            return Exercise(
                name: fromProgram.name,
                sets: fromProgram.sets,
                reps: fromProgram.reps,
                liftType: fromProgram.liftType,
                percentageOf1RM: fromProgram.percentageOf1RM,
                rpeOrNotes: fromProgram.rpeOrNotes,
                equipment: selectedEquipment
            )
        }
        return Exercise(
            name: name,
            sets: 1,
            reps: "10",
            liftType: .accessory,
            percentageOf1RM: nil,
            rpeOrNotes: "",
            equipment: selectedEquipment
        )
    }
    
    var currentEquipment: Equipment {
        workoutManager.getEquipment(for: name, defaultEquipment: defaultEquipment)
    }
    
    var currentWeight: Double? {
        database.getWeight(for: name)
    }

    var currentProgressionAmount: Double {
        workoutManager.getProgressionAmount(for: name, equipment: selectedEquipment)
    }

    var currentRestTimerDurationSeconds: Int {
        workoutManager.getRestTimerDuration(for: settingsExercise)
    }

    var defaultRestTimerDurationSeconds: Int {
        workoutManager.getDefaultRestTimerDuration(for: settingsExercise)
    }
    
    var body: some View {
        Form {
            Section(header: Text("Equipment")) {
                Picker("Type", selection: $selectedEquipment) {
                    ForEach(Equipment.allCases, id: \.self) { equipment in
                        Text(equipment.rawValue).tag(equipment)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section(header: Text("Weight")) {
                HStack {
                    Text("Current")
                    Spacer()
                    Text(currentWeight?.formattedWeight ?? "-")
                        .foregroundColor(.secondary)
                }
                
                Button("Change Weight") {
                    weightInput = currentWeight?.formattedWeight ?? ""
                    showWeightAlert = true
                }
                
                if currentWeight != nil {
                    Button("Clear Saved Weight", role: .destructive) {
                        database.clearWeight(for: name)
                    }
                }
            }

            Section(header: Text("Auto Progression")) {
                HStack {
                    Text("Amount")
                    Spacer()
                    Text("\(currentProgressionAmount.formattedWeight) lbs")
                        .foregroundColor(.secondary)
                }

                Button("Change Amount") {
                    progressionInput = currentProgressionAmount.formattedWeight
                    showProgressionAlert = true
                }

                if workoutManager.isProgressionAmountOverridden(for: name) {
                    Button("Reset to Default", role: .destructive) {
                        workoutManager.clearProgressionAmountOverride(for: name)
                    }
                }
            }

            Section(header: Text("Rest Timer")) {
                HStack {
                    Text("Duration")
                    Spacer()
                    Text(formatDuration(restTimerDurationSeconds))
                        .foregroundColor(.secondary)
                }

                Stepper("Adjust Duration", value: $restTimerDurationSeconds, in: 30...600, step: 15)

                if workoutManager.isRestTimerDurationOverridden(for: name) {
                    Button("Reset to Default", role: .destructive) {
                        workoutManager.clearRestTimerDurationOverride(for: name)
                        restTimerDurationSeconds = defaultRestTimerDurationSeconds
                    }
                }
            }
            
            if selectedEquipment == .barbell {
                Section(header: Text("Barbell Weight")) {
                    Picker("Barbell", selection: $barbellBaseWeight) {
                        Text("45 lbs (Standard)").tag(45.0)
                        Text("25 lbs (Preacher)").tag(25.0)
                        Text("15 lbs (Smith)").tag(15.0)
                    }
                    .pickerStyle(.menu)
                }
            }
        }
        .navigationTitle(name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            selectedEquipment = currentEquipment
            barbellBaseWeight = workoutManager.getBarbellBaseWeight(for: name, defaultWeight: Equipment.barbell.baseWeight)
            restTimerDurationSeconds = currentRestTimerDurationSeconds
            didInitializeRestTimer = true
        }
        .onChange(of: selectedEquipment) { _, newValue in
            workoutManager.updateEquipment(for: name, to: newValue)
            if newValue == .barbell {
                barbellBaseWeight = workoutManager.getBarbellBaseWeight(for: name, defaultWeight: Equipment.barbell.baseWeight)
            }
        }
        .onChange(of: barbellBaseWeight) { _, newValue in
            workoutManager.updateBarbellBaseWeight(for: name, to: newValue)
        }
        .onChange(of: restTimerDurationSeconds) { _, newValue in
            guard didInitializeRestTimer else { return }
            if newValue == defaultRestTimerDurationSeconds {
                workoutManager.clearRestTimerDurationOverride(for: name)
            } else {
                workoutManager.updateRestTimerDuration(for: name, to: newValue)
            }
        }
        .alert("Set Weight", isPresented: $showWeightAlert) {
            TextField("Weight", text: $weightInput)
                .keyboardType(.decimalPad)
            Button("Save") {
                if let value = Double(weightInput) {
                    database.saveWeight(for: name, weight: value)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Enter the weight for this exercise.")
        }
        .alert("Auto Progression Amount", isPresented: $showProgressionAlert) {
            TextField("Amount", text: $progressionInput)
                .keyboardType(.decimalPad)
            Button("Save") {
                if let value = Double(progressionInput) {
                    workoutManager.updateProgressionAmount(for: name, to: value)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("How many pounds should this exercise increase when progression triggers?")
        }
    }

    func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainder = seconds % 60
        return String(format: "%d:%02d", minutes, remainder)
    }
}
