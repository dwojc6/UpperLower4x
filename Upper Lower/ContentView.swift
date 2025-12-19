//
//  ContentView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @StateObject var exerciseDatabase = ExerciseDatabase()
    
    @AppStorage("squatMax") var squatMax: Double = 0.0
    @AppStorage("benchMax") var benchMax: Double = 0.0
    @AppStorage("deadliftMax") var deadliftMax: Double = 0.0
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    @State private var squatInput = ""
    @State private var benchInput = ""
    @State private var deadliftInput = ""
    
    @State private var selectedTab: Int = 0
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black
        tabBarAppearance.shadowColor = nil
        
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance
    }
    
    var body: some View {
        if !hasOnboarded {
            OnboardingView(squat: $squatInput, bench: $benchInput, deadlift: $deadliftInput) {
                saveUserData()
            }
            // CRITICAL FIX: Inject the database here so OnboardingView can access it
            .environmentObject(exerciseDatabase)
        } else {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    HomeView(
                        squatMax: $squatMax,
                        benchMax: $benchMax,
                        deadliftMax: $deadliftMax,
                        selectedTab: $selectedTab
                    )
                }
                .tabItem {
                    Label("Program", systemImage: "dumbbell.fill")
                }
                .tag(0)
                
                NavigationStack {
                    CurrentSessionTab()
                }
                .tabItem {
                    Label("Session", systemImage: "timer")
                }
                .badge(workoutManager.isSessionActive ? "ON" : nil)
                .tag(1)
                
                NavigationStack {
                    ExercisesView()
                }
                .tabItem {
                    Label("Exercises", systemImage: "list.bullet.rectangle.portrait")
                }
                .tag(2)
                
                NavigationStack {
                    HistoryView()
                }
                .tabItem {
                    Label("History", systemImage: "calendar")
                }
                .tag(3)
            }
            .accentColor(.green)
            .environmentObject(workoutManager)
            .environmentObject(exerciseDatabase)
            .preferredColorScheme(.dark)
        }
    }
    
    func saveUserData() {
        squatMax = Double(squatInput) ?? 0.0
        benchMax = Double(benchInput) ?? 0.0
        deadliftMax = Double(deadliftInput) ?? 0.0
        hasOnboarded = true
    }
}

// MARK: - Home Tab View
struct HomeView: View {
    @Binding var squatMax: Double
    @Binding var benchMax: Double
    @Binding var deadliftMax: Double
    @Binding var selectedTab: Int
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @State private var showResetAlert = false
    
    var days: [WorkoutDay] {
        ProgramData.shared.getDays(forWeek: workoutManager.currentWeek)
    }
    
    var currentUserProfile: UserProfile {
        UserProfile(squatMax: squatMax, benchMax: benchMax, deadliftMax: deadliftMax)
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            List {
                // Header Section
                Group {
                    VStack(spacing: 24) {
                        // Editable Stats
                        HStack(spacing: 12) {
                            EditableStatBadge(title: "SQUAT", value: $squatMax)
                            EditableStatBadge(title: "BENCH", value: $benchMax)
                            EditableStatBadge(title: "DEADLIFT", value: $deadliftMax)
                        }
                        .padding(.top)
                        
                        // Current Week Header
                        HStack {
                            VStack(alignment: .leading) {
                                Text("CURRENT WEEK")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                Text("Week \(workoutManager.currentWeek)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Dropdown Menu
                            Menu {
                                Picker("Select Week", selection: Binding(
                                    get: { workoutManager.currentWeek },
                                    set: { newValue in
                                        if newValue != workoutManager.currentWeek {
                                            workoutManager.jumpToWeek(newValue)
                                        }
                                    }
                                )) {
                                    ForEach(1...9, id: \.self) { week in
                                        Text("Week \(week)").tag(week)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text("Jump to")
                                    Image(systemName: "chevron.down")
                                }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(UIColor.systemGray6).opacity(0.8))
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.black)
                
                // Workout Days List
                ForEach(Array(days.enumerated()), id: \.element.id) { index, day in
                    let isLast = index == days.count - 1
                    
                    ZStack {
                        // Invisible NavigationLink covering the cell (Hides system arrow)
                        NavigationLink(destination: WorkoutDetailView(
                            day: day,
                            userProfile: currentUserProfile,
                            isSessionView: false,
                            selectedTab: $selectedTab
                        )) {
                            EmptyView()
                        }
                        .opacity(0) // Hides the arrow
                        
                        WorkoutDayCard(day: day, showSeparator: !isLast)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    .listRowBackground(Color.black)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            workoutManager.toggleDayCompletion(day: day)
                        } label: {
                            Label(workoutManager.isDayComplete(day: day) ? "Unmark" : "Complete", systemImage: "checkmark")
                        }
                        .tint(.green)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Upper Lower 4x")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showResetAlert = true
                }) {
                    Text("Reset")
                        .foregroundColor(.red)
                }
            }
        }
        .alert("Reset to Week 1?", isPresented: $showResetAlert) {
            Button("Reset", role: .destructive) {
                workoutManager.resetProgram()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will reset your schedule back to Week 1. Your completed workout history will remain saved.")
        }
    }
}

// MARK: - Session Tab View
struct CurrentSessionTab: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    
    @AppStorage("squatMax") var squatMax: Double = 0.0
    @AppStorage("benchMax") var benchMax: Double = 0.0
    @AppStorage("deadliftMax") var deadliftMax: Double = 0.0
    
    var userProfile: UserProfile {
        UserProfile(squatMax: squatMax, benchMax: benchMax, deadliftMax: deadliftMax)
    }
    
    var body: some View {
        if workoutManager.isSessionActive, let day = workoutManager.activeWorkoutDay {
            WorkoutDetailView(
                day: day,
                userProfile: userProfile,
                isSessionView: true,
                selectedTab: .constant(1)
            )
        } else {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(spacing: 20) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Active Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("Go to the Program tab to start a workout.")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

// MARK: - Editable Stat Badge
struct EditableStatBadge: View {
    let title: String
    @Binding var value: Double
    @State private var showingAlert = false
    @State private var tempInput = ""
    
    // Adaptive Fonts
    @ScaledMetric var titleSize: CGFloat = 10
    @ScaledMetric var valueSize: CGFloat = 20
    @ScaledMetric var labelSize: CGFloat = 10
    
    var body: some View {
        Button(action: {
            tempInput = "\(Int(value))"
            showingAlert = true
        }) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: titleSize, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(1)
                Text("\(Int(value))")
                    .font(.system(size: valueSize, weight: .heavy, design: .rounded))
                    .foregroundColor(.green)
                Text("lbs")
                    .font(.system(size: labelSize, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemGray6).opacity(0.3))
            .cornerRadius(12)
        }
        .buttonStyle(.borderless) // FIX: Prevents List from merging buttons
        .alert("Update \(title) Max", isPresented: $showingAlert) {
            TextField("Weight", text: $tempInput)
                .keyboardType(.decimalPad)
            Button("Save") {
                if let newVal = Double(tempInput) {
                    value = newVal
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your new 1 Rep Max.")
        }
    }
}

// MARK: - Workout Day Card
struct WorkoutDayCard: View {
    let day: WorkoutDay
    var showSeparator: Bool = true
    @EnvironmentObject var workoutManager: WorkoutManager
    
    // Adaptive Metrics
    @ScaledMetric var circleSize: CGFloat = 50
    @ScaledMetric var iconFontSize: CGFloat = 20
    @ScaledMetric var titleFontSize: CGFloat = 18
    @ScaledMetric var verticalPadding: CGFloat = 12
    
    var isCompleted: Bool {
        workoutManager.isDayComplete(day: day)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                // Icon / Number
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.gray : Color.green)
                        .frame(width: circleSize, height: circleSize)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.headline)
                            .foregroundColor(.white)
                    } else {
                        Text(day.name.replacingOccurrences(of: "Day ", with: "")
                            .replacingOccurrences(of: "Lower ", with: "L")
                            .replacingOccurrences(of: "Upper ", with: "U"))
                            .font(.system(size: iconFontSize, weight: .bold))
                            .foregroundColor(.black)
                    }
                }
                .padding(.trailing, 8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(day.name.uppercased())
                        .font(.system(size: titleFontSize, weight: .heavy))
                        .foregroundColor(.white)
                    
                    Text(isCompleted ? "Completed" : "\(day.exercises.count) Exercises")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, 16)
            
            if showSeparator {
                Divider()
                    .background(Color.gray.opacity(0.3))
            }
        }
        .opacity(isCompleted ? 0.5 : 1.0)
    }
}
