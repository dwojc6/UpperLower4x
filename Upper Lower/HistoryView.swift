//
//  HistoryView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedDate = Date()
    @State private var showSettings = false // New State
    
    // Helper to extract dates from history for the calendar
    var workoutDates: Set<DateComponents> {
        let calendar = Calendar.current
        let components = workoutManager.history.map { workout in
            calendar.dateComponents([.year, .month, .day], from: workout.startTime)
        }
        return Set(components)
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                // Custom Calendar Grid
                CalendarView(selectedDate: $selectedDate, workoutDates: workoutDates)
                    .padding()
                
                // Workouts List for Selected Date
                let workoutsOnDate = workoutManager.history.filter { Calendar.current.isDate($0.startTime, inSameDayAs: selectedDate) }
                
                if workoutsOnDate.isEmpty {
                    Spacer()
                    Text("No workouts logged for this day.")
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                } else {
                    List {
                        ForEach(workoutsOnDate) { workout in
                            ZStack {
                                // Invisible NavigationLink for tapping
                                NavigationLink(destination: SessionDetailView(workout: workout)) {
                                    EmptyView()
                                }
                                .opacity(0)
                                
                                HistoryCard(workout: workout)
                            }
                            .listRowBackground(Color.black)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        workoutManager.deleteWorkout(workout)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
        }
        .navigationTitle("History")
        // NEW TOOLBAR ITEM
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gear")
                        .foregroundColor(.green)
                }
            }
        }
        // NEW SHEET
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

// MARK: - Session Detail View
struct SessionDetailView: View {
    let workout: CompletedWorkout
    @EnvironmentObject var workoutManager: WorkoutManager
    @Environment(\.dismiss) var dismiss
    
    @ScaledMetric var setLabelWidth: CGFloat = 60
    
    // Edit Time State
    @State private var showEditTimeSheet = false
    @State private var editingStartTime = Date()
    @State private var editingEndTime = Date()
    
    // Get live update from manager so UI refreshes immediately after edit
    var liveWorkout: CompletedWorkout {
        workoutManager.history.first(where: { $0.id == workout.id }) ?? workout
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text(liveWorkout.dayName.uppercased())
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        
                        Text(liveWorkout.startTime.formatted(date: .long, time: .omitted))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        // EDITABLE TIME RANGE
                        Button(action: {
                            // Initialize state with current values
                            editingStartTime = liveWorkout.startTime
                            // Determine End Time: either use stored endTime or calc from duration
                            if let end = liveWorkout.endTime {
                                editingEndTime = end
                            } else {
                                editingEndTime = liveWorkout.startTime.addingTimeInterval(liveWorkout.duration)
                            }
                            showEditTimeSheet = true
                        }) {
                            VStack(spacing: 4) {
                                HStack(spacing: 6) {
                                    // Shows "12:00 PM - 1:30 PM"
                                    Text("\(timeString(liveWorkout.startTime)) - \(timeString(liveWorkout.endTime ?? liveWorkout.startTime.addingTimeInterval(liveWorkout.duration)))")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.green)
                                    
                                    Image(systemName: "pencil")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Text(formatDuration(liveWorkout.duration))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                            .background(Color(UIColor.systemGray6).opacity(0.3))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top)
                    
                    // Exercises List
                    if liveWorkout.exercises.isEmpty {
                        Text("No exercises logged.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(liveWorkout.exercises) { exercise in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(exercise.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                ForEach(exercise.sets) { set in
                                    HStack {
                                        Text("Set \(set.setNumber)")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.gray)
                                            .frame(width: setLabelWidth, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(set.weight)) lbs x \(set.reps)")
                                            .font(.subheadline)
                                            .fontDesign(.monospaced)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                    .padding(12)
                                    .background(Color(UIColor.systemGray6).opacity(0.5))
                                    .cornerRadius(8)
                                }
                            }
                            .padding()
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    workoutManager.deleteWorkout(workout)
                    dismiss()
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        // Sheet for editing start/end times
        .sheet(isPresented: $showEditTimeSheet) {
            NavigationView {
                Form {
                    Section(header: Text("Start Time")) {
                        // CHANGED: Added .date to components so you can fix multi-day errors
                        DatePicker("Start", selection: $editingStartTime, displayedComponents: [.hourAndMinute, .date])
                    }
                    
                    Section(header: Text("End Time")) {
                        // CHANGED: Added .date to components
                        DatePicker("End", selection: $editingEndTime, displayedComponents: [.hourAndMinute, .date])
                    }
                    
                    Section {
                        HStack {
                            Text("Total Duration")
                            Spacer()
                            Text(formatDuration(editingEndTime.timeIntervalSince(editingStartTime)))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .navigationTitle("Edit Time")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showEditTimeSheet = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            workoutManager.updateWorkoutTimes(workout, newStart: editingStartTime, newEnd: editingEndTime)
                            showEditTimeSheet = false
                        }
                    }
                }
            }
            .preferredColorScheme(.dark)
        }
    }
    
    func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let hours = minutes / 60
        let remainingMins = minutes % 60
        
        if hours > 0 {
            return "\(hours) hr \(remainingMins) mins"
        } else {
            return "\(minutes) mins"
        }
    }
}

// MARK: - History Card
struct HistoryCard: View {
    let workout: CompletedWorkout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(workout.dayName.uppercased())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Show range here too if you like, or just start time
                Text(workout.startTime.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider().background(Color.gray)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(formatDuration(workout.duration))
                        .font(.headline)
                        .foregroundColor(.green)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Exercises")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(workout.exercises.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
}
