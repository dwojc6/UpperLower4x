//
//  WorkoutDetailView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI
import Combine

struct WorkoutDetailView: View {
    let day: WorkoutDay
    let userProfile: UserProfile
    
    var isSessionView: Bool
    @Binding var selectedTab: Int
    
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var database: ExerciseDatabase
    @Environment(\.dismiss) var dismiss
    
    @State private var editMode: EditMode = .inactive
    @State private var showEndWorkoutAlert = false
    @State private var showAddExerciseSheet = false
    
    // Local list for display and reordering
    @State private var exercisesList: [Exercise] = []
    
    // Menu States
    @State private var exerciseToEdit: Exercise?
    @State private var showWeightAlert = false
    @State private var showRepsAlert = false
    @State private var weightInput = ""
    @State private var repsInput = ""
    
    // MARK: - Adaptive Metrics
    @ScaledMetric var endButtonHeight: CGFloat = 38
    @ScaledMetric var endButtonBottomPadding: CGFloat = 10
    
    @ScaledMetric var menuWidth: CGFloat = 300
    @ScaledMetric var menuButtonHeight: CGFloat = 50
    
    @ScaledMetric var triangleWidth: CGFloat = 25
    @ScaledMetric var triangleHeight: CGFloat = 15
    
    // Gap between button top and triangle tip
    @ScaledMetric var menuGap: CGFloat = 7
    
    var alertBottomPadding: CGFloat {
        // Calculate dynamic position: Button Height + Bottom Padding + Gap
        return endButtonHeight + endButtonBottomPadding + menuGap
    }
    
    // Computed: Find history for this specific day/week
    var historicalWorkout: CompletedWorkout? {
        workoutManager.getHistory(for: day)
    }
    
    // Computed property for the unique schedule key
    var scheduleKey: String {
        workoutManager.getScheduleKey(week: day.week, dayName: day.name)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // 1. Main Content List
            contentList
            
            // 2. Pinned End Workout Button
            if isSessionView && workoutManager.isSessionActive {
                pinnedEndWorkoutButton
                    .transition(.opacity)
                    .zIndex(1)
            }
            
            // 3. Custom Save/Discard Alert Overlay
            if showEndWorkoutAlert {
                Color.clear
                    .contentShape(Rectangle())
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation { showEndWorkoutAlert = false }
                    }
                    .transition(.opacity)
                    .zIndex(2)
                
                VStack {
                    Spacer()
                    customSaveAlert
                        .padding(.bottom, alertBottomPadding) // Adaptive padding
                        .transition(.scale(scale: 0.1, anchor: .bottom).combined(with: .opacity))
                }
                .zIndex(3)
            }
        }
        .onAppear {
            loadAndSortExercises()
        }
        // UPDATED: Watch specific week keys for changes
        .onChange(of: workoutManager.addedExercises[scheduleKey]) { _ in loadAndSortExercises() }
        .onChange(of: workoutManager.removedDefaultExercises[scheduleKey]) { _ in loadAndSortExercises() }
        .onChange(of: workoutManager.exerciseOrder[day.name]) { _ in loadAndSortExercises() }
        .onChange(of: workoutManager.overriddenEquipment) { _ in loadAndSortExercises() }
        
        // Pass local edit mode state to environment
        .environment(\.editMode, $editMode)
        
        .toolbar {
            toolbarItems
        }
        .sheet(isPresented: $showAddExerciseSheet) {
            // UPDATED: Pass the full day object
            AddExerciseToDaySheet(day: day)
        }
        .alert("Set Weight (lbs)", isPresented: $showWeightAlert) {
            TextField("Weight", text: $weightInput).keyboardType(.decimalPad)
            Button("Save") {
                if let ex = exerciseToEdit, let w = Double(weightInput) {
                    database.saveWeight(for: ex.name, weight: w)
                    loadAndSortExercises()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Set Reps", isPresented: $showRepsAlert) {
            TextField("Reps (e.g., 10, 8-12)", text: $repsInput)
            Button("Save") {
                if let ex = exerciseToEdit {
                    workoutManager.updateReps(for: ex.name, reps: repsInput)
                    loadAndSortExercises()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Custom Alert View
    var customSaveAlert: some View {
        VStack(spacing: 0) {
            
            // Bubble Content
            VStack(spacing: 16) {
                Text("Save workout?")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(workoutManager.isCurrentSessionComplete
                     ? "You have completed all exercises. Do you want to save your workout?"
                     : "Some exercises are not logged. Do you want to save your workout anyway?")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 10)
                
                VStack(spacing: 10) {
                    // Save Button
                    Button(action: {
                        withAnimation {
                            workoutManager.endSession(save: true, database: database)
                            showEndWorkoutAlert = false
                            dismiss()
                        }
                    }) {
                        Text("Save Workout")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: menuButtonHeight) // ADAPTIVE
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                    
                    // Discard Button
                    Button(action: {
                        withAnimation {
                            workoutManager.endSession(save: false)
                            showEndWorkoutAlert = false
                            dismiss()
                        }
                    }) {
                        Text("Discard Workout")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: menuButtonHeight) // ADAPTIVE
                            .background(Color(UIColor.systemGray3))
                            .clipShape(Capsule())
                    }
                }
                .padding(.top, 5)
            }
            .padding(24)
            .background(Color(UIColor.systemGray6))
            .cornerRadius(25)
            
            // Triangle Tail
            Triangle()
                .fill(Color(UIColor.systemGray6))
                .frame(width: triangleWidth, height: triangleHeight) // ADAPTIVE
                .offset(y: -1)
        }
        .frame(width: menuWidth) // ADAPTIVE
        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
    }
    
    // MARK: - Subviews
    
    var contentList: some View {
        List {
            headerSection
            exercisesListSection
            
            // Spacer for Pinned Button
            if isSessionView && workoutManager.isSessionActive {
                Color.clear
                    .frame(height: endButtonHeight + endButtonBottomPadding + 20)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSessionView && workoutManager.isSessionActive {
                    Button(action: {
                        workoutManager.togglePause()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: workoutManager.isTimerPaused ? "pause.circle.fill" : "timer")
                                .foregroundColor(workoutManager.isTimerPaused ? .yellow : .green)
                            Text(workoutManager.formattedTime)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(workoutManager.isTimerPaused ? .yellow : .green)
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        withAnimation {
                            if editMode == .active {
                                editMode = .inactive
                            } else {
                                editMode = .active
                            }
                        }
                    }) {
                        Image(systemName: editMode == .active ? "checkmark.circle.fill" : "arrow.up.arrow.down")
                            .font(.system(size: 16, weight: .bold)) // Consider removing fixed size here too, but SF symbols scale mostly ok
                            .foregroundColor(.green)
                    }
                    
                    Button(action: {
                        showAddExerciseSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    // Pinned button implementation
    var pinnedEndWorkoutButton: some View {
        VStack {
            Button(action: {
                withAnimation {
                    showEndWorkoutAlert = true
                }
            }) {
                Text("End workout")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: endButtonHeight) // ADAPTIVE
                    .background(Color.red)
                    .clipShape(Capsule()) // Replaces fixed cornerRadius for perfect pill
            }
            .padding(.horizontal, 40)
            .padding(.bottom, endButtonBottomPadding) // ADAPTIVE
        }
        .background(
            LinearGradient(colors: [.black.opacity(0), .black], startPoint: .top, endPoint: .bottom)
                .frame(height: endButtonHeight + endButtonBottomPadding + 20)
                .padding(.top, -20)
        )
    }
    
    var headerSection: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading) {
                    Text(day.name.uppercased())
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    Text("Week \(day.week)")
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                if !isSessionView && !workoutManager.isSessionActive {
                    Button(action: {
                        workoutManager.startSession(day: day)
                        selectedTab = 1
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text("START")
                                .fontWeight(.bold)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(20)
                    }
                }
            }
            .padding(.top)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
    }
    
    var exercisesListSection: some View {
        ForEach(Array(exercisesList.enumerated()), id: \.element.id) { index, exercise in
            let connection = getSupersetConnection(for: exercise, at: index, in: exercisesList)
            
            ZStack {
                NavigationLink(destination: ExerciseDetailView(
                    day: day,
                    initialExercise: exercise,
                    fullDayExercises: exercisesList,
                    userProfile: userProfile,
                    isSessionView: isSessionView,
                    historicalWorkout: historicalWorkout
                )) {
                    EmptyView()
                }
                .opacity(0)
                
                ExerciseRow(
                    exercise: exercise,
                    userProfile: userProfile,
                    connectedUp: connection.up,
                    connectedDown: connection.down,
                    showSeparator: index < exercisesList.count - 1,
                    isSessionView: isSessionView,
                    historicalWorkout: historicalWorkout,
                    isEditing: editMode == .active,
                    isDayComplete: workoutManager.isDayComplete(day: day)
                )
            }
            .listRowBackground(Color.black)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    withAnimation {
                        // UPDATED: Pass the full day object
                        workoutManager.removeExerciseFromSchedule(day: day, exercise: exercise)
                    }
                } label: {
                    Label("Remove", systemImage: "trash")
                }
                .tint(.red)
            }
            .contextMenu {
                contextMenuButtons(for: exercise, in: exercisesList)
            }
        }
        .onMove(perform: moveExercises)
    }
    
    @ViewBuilder
    func contextMenuButtons(for exercise: Exercise, in list: [Exercise]) -> some View {
        Button {
            exerciseToEdit = exercise
            weightInput = "\(Int(database.getWeight(for: exercise.name) ?? 0))"
            showWeightAlert = true
        } label: {
            Label("Change Weight", systemImage: "scalemass")
        }
        
        Button {
            exerciseToEdit = exercise
            repsInput = workoutManager.getReps(for: exercise.name, defaultReps: exercise.reps)
            showRepsAlert = true
        } label: {
            Label("Change Reps", systemImage: "arrow.triangle.2.circlepath")
        }
        
        if let _ = workoutManager.getSupersetPartners(for: exercise.name, dayName: day.name) {
            Button(role: .destructive) {
                workoutManager.removeSuperset(for: exercise.name, dayName: day.name)
            } label: {
                Label("Disconnect Superset", systemImage: "link")
            }
        } else {
            if let neighbors = getNeighbors(for: exercise, in: list) {
                if let prev = neighbors.prev {
                    Button {
                        workoutManager.createSuperset(dayName: day.name, exerciseNames: [exercise.name, prev.name])
                    } label: {
                        Label("Superset with \(prev.name)", systemImage: "link")
                    }
                }
                if let next = neighbors.next {
                    Button {
                        workoutManager.createSuperset(dayName: day.name, exerciseNames: [exercise.name, next.name])
                    } label: {
                        Label("Superset with \(next.name)", systemImage: "link")
                    }
                }
            }
        }
    }
    
    // MARK: - Logic Helpers
    func getNeighbors(for exercise: Exercise, in exercises: [Exercise]) -> (prev: Exercise?, next: Exercise?)? {
        guard let idx = exercises.firstIndex(where: { $0.id == exercise.id }) else { return nil }
        let prev = idx > 0 ? exercises[idx - 1] : nil
        let next = idx < exercises.count - 1 ? exercises[idx + 1] : nil
        return (prev, next)
    }
    
    func getSupersetConnection(for exercise: Exercise, at index: Int, in exercises: [Exercise]) -> (up: Bool, down: Bool) {
        guard let partners = workoutManager.getSupersetPartners(for: exercise.name, dayName: day.name) else {
            return (false, false)
        }
        
        let up = index > 0 && partners.contains(exercises[index - 1].name)
        let down = index < exercises.count - 1 && partners.contains(exercises[index + 1].name)
        
        return (up, down)
    }
    
    func loadAndSortExercises() {
        // UPDATED: Use the new key to load/filter exercises for this specific week
        let defaults = day.exercises.filter {
            !(workoutManager.removedDefaultExercises[scheduleKey]?.contains($0.name) ?? false)
        }
        let added = workoutManager.addedExercises[scheduleKey] ?? []
        var combined = defaults + added
        
        if let savedOrder = workoutManager.exerciseOrder[day.name] {
            var orderMap = [String: Int]()
            for (index, name) in savedOrder.enumerated() {
                orderMap[name] = index
            }
            combined.sort { (ex1, ex2) -> Bool in
                let idx1 = orderMap[ex1.name] ?? Int.max
                let idx2 = orderMap[ex2.name] ?? Int.max
                return idx1 < idx2
            }
        }
        
        self.exercisesList = combined.map { workoutManager.getEffectiveExercise($0) }
    }
    
    func moveExercises(from source: IndexSet, to destination: Int) {
        exercisesList.move(fromOffsets: source, toOffset: destination)
        workoutManager.saveNewOrder(dayName: day.name, exercises: exercisesList)
    }
}

// MARK: - Triangle Shape Helper
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}
