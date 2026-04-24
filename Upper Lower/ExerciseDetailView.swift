//
//  ExerciseDetailView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI

struct ExerciseDetailView: View {
    let day: WorkoutDay
    let initialExercise: Exercise
    let fullDayExercises: [Exercise]
    let userProfile: UserProfile

    var isSessionView: Bool
    var historicalWorkout: CompletedWorkout? = nil
    var onEditNote: ((Exercise) -> Void)? = nil
    
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var database: ExerciseDatabase
    @Environment(\.dismiss) var dismiss
    
    // Main View States (Weights/Completion)
    @State private var showEmptyWeightAlert = false
    @State private var pendingWeightInput = ""
    @State private var pendingSetIndex: Int?
    @State private var pendingExercise: Exercise?
    @State private var isWarmupExpanded = true
    @State private var pendingCompletionDismissWorkItem: DispatchWorkItem?
    
    // AMRAP States
    @State private var showAmrapInputAlert = false
    @State private var amrapRepsInput = ""
    @State private var currentAmrapSetIndex: Int?
    
    // ADAPTIVE METRICS
    @ScaledMetric var warmupPadding: CGFloat = 10
    
    private let completionDismissDelay: TimeInterval = 2.0
    
    // Filter by name and APPLY OVERRIDES
    var exercises: [Exercise] {
        let list: [Exercise]
        if let partnerNames = workoutManager.getSupersetPartners(for: initialExercise.name, dayName: day.name) {
            list = fullDayExercises.filter { partnerNames.contains($0.name) }
        } else {
            list = [initialExercise]
        }
        return list.map { workoutManager.getEffectiveExercise($0) }
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack {
                // MARK: - HEADER SECTION
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(exercises) { exercise in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(exercise.name.uppercased())
                                .font(.title2)
                                .fontWeight(.heavy)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Text(exercise.equipment.rawValue.uppercased())
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .tracking(0.8)
                            
                            if !exercise.rpeOrNotes.isEmpty {
                                Text(exercise.rpeOrNotes)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                ScrollView {
                    VStack(spacing: 16) { // Reduced spacing between sections
                        if isSessionView, let firstEx = exercises.first {
                            warmupSection(for: firstEx)
                        }
                        workingSetsSection
                    }
                    .padding(.bottom, 24)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if isSessionView && workoutManager.isRestTimerActive && !workoutManager.isCurrentSessionComplete {
                CompactTimerView(
                    timeRemaining: $workoutManager.restTimeRemaining,
                    isPaused: workoutManager.isRestTimerPaused,
                    onAdd: { workoutManager.addRestTime(seconds: 30) },
                    onSkip: { workoutManager.skipRestTimer() },
                    onPause: { workoutManager.toggleRestTimerPause() }
                )
                .padding(.horizontal)
                .padding(.bottom, 8)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            if isSessionView {
                checkMissingWeights()
            }
        }
        .onDisappear {
            cancelPendingCompletionDismiss()
        }
        .toolbar {
            // MARK: - ISOLATED TOOLBAR ITEMS
            // 1. Timer Button
            if isSessionView && workoutManager.isSessionActive {
                ToolbarItem(placement: .navigationBarTrailing) {
                    SessionTimerButton()
                }
            }
            
            // 2. Menu Button
            ToolbarItem(placement: .navigationBarTrailing) {
                ExerciseMenuButton(
                    exercises: exercises,
                    database: database,
                    workoutManager: workoutManager,
                    barbellBaseWeights: workoutManager.overriddenBarbellWeights,
                    onEditNote: onEditNote
                )
            }
        }
        .alert("Set Weight (lbs)", isPresented: $showEmptyWeightAlert) {
            TextField("Weight", text: $pendingWeightInput).keyboardType(.decimalPad)
            Button("Save") {
                if let w = Double(pendingWeightInput), let ex = pendingExercise {
                    database.saveWeight(for: ex.name, weight: w)
                    if let idx = pendingSetIndex {
                        handleRepTap(exercise: ex, index: idx)
                    }
                }
                pendingSetIndex = nil
                pendingExercise = nil
                pendingWeightInput = ""
            }
            Button("Cancel", role: .cancel) {
                pendingSetIndex = nil
                pendingExercise = nil
            }
        } message: {
            if let ex = pendingExercise {
                Text("Enter the weight for \(ex.name) to continue.")
            } else {
                Text("Please enter a weight.")
            }
        }
        .alert("AMRAP Result", isPresented: $showAmrapInputAlert) {
            TextField("Reps completed", text: $amrapRepsInput)
                .keyboardType(.numberPad)
            
            Button("Save") {
                if let ex = pendingExercise, let idx = currentAmrapSetIndex, let reps = Int(amrapRepsInput) {
                    updateSetLog(exercise: ex, index: idx, reps: reps)
                }
                pendingExercise = nil
                currentAmrapSetIndex = nil
                amrapRepsInput = ""
            }
            Button("Cancel", role: .cancel) {
                pendingExercise = nil
                currentAmrapSetIndex = nil
            }
        } message: {
            Text("How many reps did you complete?")
        }
    }
    
    @ViewBuilder
    func warmupSection(for exercise: Exercise) -> some View {
        let wSets = calculateWarmups(for: exercise)
        let completed = workoutManager.completedWarmups[exercise.id] ?? []
        
        // CHANGED: Removed '&& completed.count < wSets.count' so the section stays visible
        if !wSets.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                // CHANGED: Header is now a tappable Button
                Button {
                    withAnimation {
                        isWarmupExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("WARM UP")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        // Show checkmark in header if all warmups are done
                        if completed.count == wSets.count {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                        
                        // Chevron indicator
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .rotationEffect(isWarmupExpanded ? .zero : .degrees(-90))
                    }
                    .padding(.leading, 4)
                }
                .buttonStyle(.plain) // Prevents interference with list interactions
                
                // CHANGED: Only show rows if expanded
                if isWarmupExpanded {
                    ForEach(0..<wSets.count, id: \.self) { index in
                        let w = wSets[index]
                        let isCompleted = completed.contains(index)
                        
                        HStack {
                            Text("Warmup \(index + 1)").font(.subheadline).foregroundColor(.gray)
                            Spacer()
                            
                            VStack(spacing: 2) {
                                Text("\(Int(w.weight)) lbs x \(w.reps)")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                let baseOverride = workoutManager.getBarbellBaseWeight(for: exercise.name, defaultWeight: exercise.equipment.baseWeight)
                                if let plates = exercise.equipment.getPlateBreakdown(for: w.weight, baseWeightOverride: baseOverride) {
                                    Text(plates)
                                        .font(.caption2)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            Spacer()
                            Button(action: {
                                if isSessionView {
                                    withAnimation {
                                        if !workoutManager.isSessionActive {
                                            workoutManager.startSession(day: day)
                                        }
                                        workoutManager.toggleWarmup(for: exercise.id, index: index)
                                    }
                                }
                            }) {
                                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.title2)
                                    .foregroundColor(isCompleted ? .orange : .gray)
                            }
                            .disabled(!isSessionView)
                        }
                        .padding(warmupPadding)
                        .background(Color(UIColor.systemGray6).opacity(0.5))
                        .cornerRadius(12)
                        .opacity(isCompleted ? 0.6 : 1.0)
                    }
                }
            }
            .padding(.horizontal)
            .transition(.opacity)
            // CHANGED: Auto-collapse when all sets are completed
            .onChange(of: completed) { oldValue, newValue in
                if newValue.count == wSets.count {
                    withAnimation {
                        isWarmupExpanded = false
                    }
                }
            }
            // Ensure correct initial state when view loads
            .onAppear {
                if completed.count == wSets.count {
                    isWarmupExpanded = false
                }
            }
        }
    }
    
    var workingSetsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("WORKING SETS").font(.caption).fontWeight(.bold).foregroundColor(.green).padding(.leading, 4)
            let maxSets = exercises.map { $0.sets }.max() ?? 0
            ForEach(0..<maxSets, id: \.self) { setIndex in
                ForEach(exercises) { exercise in
                    if setIndex < exercise.sets {
                        ExerciseSetRow(
                            exercise: exercise,
                            setIndex: setIndex,
                            weight: getWeight(for: exercise),
                            reps: getReps(for: exercise),
                            completedReps: getSetStatus(exercise: exercise, index: setIndex),
                            showExerciseName: exercises.count > 1,
                            isSessionView: isSessionView || historicalWorkout != nil,
                            onTap: {
                                if isSessionView {
                                    handleRepTap(exercise: exercise, index: setIndex)
                                }
                            },
                            onLongPress: {
                                if isSessionView {
                                    handleRepLongPress(exercise: exercise, index: setIndex)
                                }
                            }
                        )
                    }
                }
                if exercises.count > 1 && setIndex < maxSets - 1 {
                    Divider().background(Color.gray.opacity(0.3)).padding(.vertical, 4)
                }
            }
        }
        .padding(.horizontal)
    }
    
    func roundWeight(_ weight: Double) -> Double {
        return (weight / 5.0).rounded(.toNearestOrAwayFromZero) * 5.0
    }
    
    // MARK: - Updated Warmup Logic
    func calculateWarmups(for exercise: Exercise) -> [(weight: Double, reps: Int)] {
        guard [.squat, .bench, .deadlift].contains(exercise.liftType) else { return [] }
        let w = getWeight(for: exercise)
        let bar = workoutManager.getBarbellBaseWeight(for: exercise.name, defaultWeight: exercise.equipment.baseWeight)
        
        // 1. 10 reps x Empty Bar
        let s1 = (bar, 10)
        
        // 2. 5 reps x 50%
        let s2 = (roundWeight(w * 0.50), 5)
        
        // 3. 5 reps x 65%
        let s3 = (roundWeight(w * 0.65), 5)
        
        // 4. 5 reps x 80%
        let s4 = (roundWeight(w * 0.80), 5)
        
        return [s1, s2, s3, s4]
    }
    
    func getWeight(for exercise: Exercise) -> Double {
        if let saved = database.getWeight(for: exercise.name) { return saved }
        return exercise.targetWeight(userProfile: userProfile) ?? 0
    }
    
    func getReps(for exercise: Exercise) -> String {
        return workoutManager.getReps(for: exercise.name, defaultReps: exercise.reps)
    }
    
    func getSetStatus(exercise: Exercise, index: Int) -> Int? {
        let source: CompletedWorkout?
        if isSessionView {
            source = workoutManager.currentSession
        } else {
            source = historicalWorkout
        }
        
        guard let session = source else { return nil }
        
        if let exerciseLog = session.exercises.first(where: { $0.name == exercise.name }) {
            if let setLog = exerciseLog.sets.first(where: { $0.setNumber == index + 1 }) {
                return Int(setLog.reps.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
            }
        }
        return nil
    }
    
    func checkMissingWeights() {
        for ex in exercises {
            if ex.equipment == .bodyweight { continue }
            
            if getWeight(for: ex) == 0 {
                self.pendingExercise = ex
                self.pendingSetIndex = nil
                self.pendingWeightInput = ""
                self.showEmptyWeightAlert = true
                return
            }
        }
    }
    
    func handleRepTap(exercise: Exercise, index: Int) {
        if exercise.equipment != .bodyweight {
            let currentWeight = getWeight(for: exercise)
            if currentWeight == 0 {
                self.pendingExercise = exercise
                self.pendingSetIndex = index
                self.pendingWeightInput = ""
                self.showEmptyWeightAlert = true
                return
            }
        }
        
        // AMRAP logic
        if exercise.reps.localizedCaseInsensitiveContains("AMRAP") {
            if getSetStatus(exercise: exercise, index: index) != nil {
                updateSetLog(exercise: exercise, index: index, reps: nil)
            } else {
                self.pendingExercise = exercise
                self.currentAmrapSetIndex = index
                self.amrapRepsInput = ""
                self.showAmrapInputAlert = true
            }
            return
        }
        
        // Time-based logic
        if exercise.reps.contains(":") {
            if getSetStatus(exercise: exercise, index: index) != nil {
                updateSetLog(exercise: exercise, index: index, reps: nil)
            } else {
                let cleanString = exercise.reps.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                let target = Int(cleanString) ?? 0
                updateSetLog(exercise: exercise, index: index, reps: target)
            }
            return
        }
        
        let currentStatus = getSetStatus(exercise: exercise, index: index)
        let repsStr = getReps(for: exercise)
        let targetRepsStr = repsStr.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let targetReps = Int(targetRepsStr) ?? 0
        
        var newReps: Int?
        if currentStatus == nil { newReps = targetReps }
        else if let current = currentStatus, current > 1 { newReps = current - 1 }
        else { newReps = nil }
        
        updateSetLog(exercise: exercise, index: index, reps: newReps)
    }

    func handleRepLongPress(exercise: Exercise, index: Int) {
        guard getSetStatus(exercise: exercise, index: index) != nil else { return }
        updateSetLog(exercise: exercise, index: index, reps: nil)
    }
    
    func updateSetLog(exercise: Exercise, index: Int, reps: Int?) {
        withAnimation {
            cancelPendingCompletionDismiss()
            
            if var session = workoutManager.currentSession {
                if let exIndex = session.exercises.firstIndex(where: { $0.name == exercise.name }) {
                    session.exercises[exIndex].sets.removeAll(where: { $0.setNumber == index + 1 })
                    if session.exercises[exIndex].sets.isEmpty && reps == nil {
                         session.exercises.remove(at: exIndex)
                    }
                    workoutManager.currentSession = session
                }
            }
            
            if let repsValue = reps {
                if !workoutManager.isSessionActive { workoutManager.startSession(day: day) }
                
                workoutManager.logSet(
                    exerciseId: exercise.id,
                    exerciseName: exercise.name,
                    setIndex: index,
                    weight: getWeight(for: exercise),
                    reps: "\(repsValue)"
                )
                
                if exercise.id == exercises.last?.id {
                    workoutManager.startRestTimer(duration: workoutManager.getRestTimerDuration(for: exercise))
                }
                
                checkCompletionAndDismiss()
            }
        }
    }
    
    func checkCompletionAndDismiss() {
        guard areAllExercisesCompleted() else { return }
        
        let workItem = DispatchWorkItem {
            if areAllExercisesCompleted() {
                dismiss()
            }
            pendingCompletionDismissWorkItem = nil
        }
        
        pendingCompletionDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + completionDismissDelay, execute: workItem)
    }
    
    func areAllExercisesCompleted() -> Bool {
        guard let session = workoutManager.currentSession else { return false }
        
        return exercises.allSatisfy { exercise in
            if let logged = session.exercises.first(where: { $0.name == exercise.name }) {
                return logged.sets.count >= exercise.sets
            }
            return false
        }
    }
    
    func cancelPendingCompletionDismiss() {
        pendingCompletionDismissWorkItem?.cancel()
        pendingCompletionDismissWorkItem = nil
    }
}
