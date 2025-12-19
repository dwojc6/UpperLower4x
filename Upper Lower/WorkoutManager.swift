//
//  WorkoutManager.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI
import Combine
import UserNotifications

class WorkoutManager: ObservableObject {
    // Active Session State
    @Published var isSessionActive = false
    @Published var activeWorkoutDay: WorkoutDay?
    @Published var currentSession: CompletedWorkout?
    @Published var elapsedSeconds: Int = 0
    @Published var isTimerPaused: Bool = false
    
    // REST TIMER STATE
    @Published var restTimeRemaining: Int = 120
    @Published var isRestTimerActive: Bool = false
    @Published var isRestTimerPaused: Bool = false
    
    // WARMUP STATE
    @Published var completedWarmups: [UUID: Set<Int>] = [:]
    
    // Progression State
    @Published var currentWeek: Int = 1
    @Published var completedDaysByWeek: [Int: [String]] = [:]
    
    // Schedule Modifications
    // KEYS are "Week-DayName"
    @Published var addedExercises: [String: [Exercise]] = [:]
    @Published var removedDefaultExercises: [String: [String]] = [:]
    @Published var overriddenReps: [String: String] = [:]
    @Published var overriddenEquipment: [String: Equipment] = [:]
    
    // Exercise Order Persistence
    @Published var exerciseOrder: [String: [String]] = [:]
    @Published var supersets: [String: [Set<String>]] = [:]
    @Published var history: [CompletedWorkout] = []
    
    private var programTimer: AnyCancellable?
    private var restTimer: AnyCancellable?
    private var lastBackgroundDate: Date?
    
    // CONSTANTS
    private let kSessionActive = "wm_session_active"
    private let kActiveDay = "wm_active_day"
    private let kCurrentSession = "wm_current_session"
    private let kElapsedSeconds = "wm_elapsed_seconds"
    private let kIsTimerPaused = "wm_is_timer_paused"
    private let kLastSavedDate = "wm_last_saved_date"
    private let kCompletedWarmups = "wm_completed_warmups"
    private let kRestTimeRemaining = "wm_rest_time_remaining"
    private let kIsRestTimerActive = "wm_is_rest_timer_active"
    private let kIsRestTimerPaused = "wm_is_rest_timer_paused"
    
    init() {
        reloadAllData()
        requestNotificationPermission()
        restoreSessionState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveSessionState), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveSessionState), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    func reloadAllData() {
        loadHistory()
        loadProgression()
        loadScheduleModifications()
        loadSupersets()
        loadExerciseOrder()
    }
    
    // MARK: - Helper for Schedule Keys
    func getScheduleKey(week: Int, dayName: String) -> String {
        return "\(week)-\(dayName)"
    }
    
    // MARK: - Completion Check Helper
    func isDayComplete(day: WorkoutDay) -> Bool {
        return completedDaysByWeek[day.week]?.contains(day.name) ?? false
    }
    
    var isCurrentSessionComplete: Bool {
        guard let day = activeWorkoutDay, let session = currentSession else { return false }
        
        let key = getScheduleKey(week: day.week, dayName: day.name)
        
        let defaults = day.exercises.filter {
            !(removedDefaultExercises[key]?.contains($0.name) ?? false)
        }
        let added = addedExercises[key] ?? []
        let plannedExercises = defaults + added
        
        for exercise in plannedExercises {
            if let logged = session.exercises.first(where: { $0.name == exercise.name }) {
                if logged.sets.count < exercise.sets {
                    return false
                }
            } else {
                return false
            }
        }
        
        return true
    }
    
    func getHistory(for day: WorkoutDay) -> CompletedWorkout? {
        return history.last {
            let logWeek = $0.week ?? 1
            return $0.dayName == day.name && logWeek == day.week
        }
    }
    
    func toggleDayCompletion(day: WorkoutDay) {
        if completedDaysByWeek[day.week] == nil {
            completedDaysByWeek[day.week] = []
        }
        
        if let index = completedDaysByWeek[day.week]?.firstIndex(of: day.name) {
            completedDaysByWeek[day.week]?.remove(at: index)
        } else {
            completedDaysByWeek[day.week]?.append(day.name)
            checkWeekCompletion(week: day.week)
        }
        saveProgression()
    }
    
    func toggleWarmup(for exerciseId: UUID, index: Int) {
        if completedWarmups[exerciseId] == nil {
            completedWarmups[exerciseId] = []
        }
        
        if completedWarmups[exerciseId]?.contains(index) == true {
            completedWarmups[exerciseId]?.remove(index)
        } else {
            completedWarmups[exerciseId]?.insert(index)
        }
        saveSessionState()
    }
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func startRestTimer(duration: Int = 120) {
        restTimeRemaining = duration
        isRestTimerActive = true
        isRestTimerPaused = false
        
        scheduleRestNotification(seconds: Double(duration))
        
        restTimer?.cancel()
        restTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.isRestTimerActive && !self.isRestTimerPaused {
                    if self.restTimeRemaining > 0 {
                        self.restTimeRemaining -= 1
                    } else {
                        self.endRestTimer()
                    }
                }
            }
        saveSessionState()
    }
    
    func toggleRestTimerPause() {
        isRestTimerPaused.toggle()
        
        if isRestTimerPaused {
            cancelRestNotification()
        } else {
            scheduleRestNotification(seconds: Double(restTimeRemaining))
        }
        saveSessionState()
    }
    
    func addRestTime(seconds: Int) {
        restTimeRemaining += seconds
        
        if !isRestTimerPaused {
            scheduleRestNotification(seconds: Double(restTimeRemaining))
        }
        saveSessionState()
    }
    
    func skipRestTimer() {
        endRestTimer()
    }
    
    private func endRestTimer() {
        isRestTimerActive = false
        restTimer?.cancel()
        restTimer = nil
        cancelRestNotification()
        saveSessionState()
    }
    
    private func scheduleRestNotification(seconds: Double) {
        cancelRestNotification()
        guard seconds > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Rest Complete"
        content.body = "Time to get back to work!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(identifier: "rest_timer_done", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelRestNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["rest_timer_done"])
    }
    
    func handleAppBackgrounding() {
        lastBackgroundDate = Date()
        saveSessionState()
    }
    
    func handleAppForegrounding() {
        guard let lastDate = lastBackgroundDate else { return }
        let timePassed = Date().timeIntervalSince(lastDate)
        
        if isSessionActive && !isTimerPaused {
            // Safety check: Don't count time if app was backgrounded > 24h
            if timePassed < 86400 {
                elapsedSeconds += Int(timePassed)
            } else {
                isTimerPaused = true
            }
        }
        
        if isRestTimerActive && !isRestTimerPaused {
            let newTime = restTimeRemaining - Int(timePassed)
            if newTime <= 0 {
                restTimeRemaining = 0
                endRestTimer()
            } else {
                restTimeRemaining = newTime
            }
        }
        lastBackgroundDate = nil
    }
    
    func updateReps(for exerciseName: String, reps: String) {
        overriddenReps[exerciseName] = reps
        saveScheduleModifications()
    }
    
    func getReps(for exerciseName: String, defaultReps: String) -> String {
        return overriddenReps[exerciseName] ?? defaultReps
    }
    
    func updateEquipment(for exerciseName: String, to equipment: Equipment) {
        overriddenEquipment[exerciseName] = equipment
        saveScheduleModifications()
    }
    
    func getEquipment(for exerciseName: String, defaultEquipment: Equipment) -> Equipment {
        return overriddenEquipment[exerciseName] ?? defaultEquipment
    }
    
    func getEffectiveExercise(_ exercise: Exercise) -> Exercise {
        var modified = exercise
        if let newEq = overriddenEquipment[exercise.name] {
            modified.equipment = newEq
        }
        return modified
    }
    
    func createSuperset(dayName: String, exerciseNames: [String]) {
        if supersets[dayName] == nil { supersets[dayName] = [] }
        let newSet = Set(exerciseNames)
        
        supersets[dayName]?.removeAll(where: { !newSet.isDisjoint(with: $0) })
        supersets[dayName]?.append(newSet)
        saveSupersets()
    }
    
    func getSupersetPartners(for exerciseName: String, dayName: String) -> Set<String>? {
        return supersets[dayName]?.first(where: { $0.contains(exerciseName) })
    }
    
    func removeSuperset(for exerciseName: String, dayName: String) {
        supersets[dayName]?.removeAll(where: { $0.contains(exerciseName) })
        saveSupersets()
    }
    
    private func saveSupersets() {
        if let encoded = try? JSONEncoder().encode(supersets) {
            UserDefaults.standard.set(encoded, forKey: "workout_supersets_v2")
        }
    }
    
    private func loadSupersets() {
        if let data = UserDefaults.standard.data(forKey: "workout_supersets_v2"),
           let decoded = try? JSONDecoder().decode([String: [Set<String>]].self, from: data) {
            supersets = decoded
        }
    }
    
    func saveNewOrder(dayName: String, exercises: [Exercise]) {
        let orderedNames = exercises.map { $0.name }
        exerciseOrder[dayName] = orderedNames
        saveExerciseOrder()
    }
    
    private func saveExerciseOrder() {
        if let encoded = try? JSONEncoder().encode(exerciseOrder) {
            UserDefaults.standard.set(encoded, forKey: "workout_exercise_order")
        }
    }
    
    private func loadExerciseOrder() {
        if let data = UserDefaults.standard.data(forKey: "workout_exercise_order"),
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            exerciseOrder = decoded
        }
    }
    
    func startSession(day: WorkoutDay) {
        if isSessionActive { return }
        isSessionActive = true
        activeWorkoutDay = day
        currentSession = CompletedWorkout(dayName: day.name, week: day.week, startTime: Date(), exercises: [])
        elapsedSeconds = 0
        isTimerPaused = false
        
        startProgramTimer()
        saveSessionState()
    }
    
    func endSession(save: Bool, database: ExerciseDatabase? = nil) {
        stopProgramTimer()
        skipRestTimer()
        
        if save, var session = currentSession {
            session.endTime = Date()
            session.duration = TimeInterval(elapsedSeconds)
            if let day = activeWorkoutDay {
                session.week = day.week
            }
            
            if let db = database, let activeDay = activeWorkoutDay {
                applyProgressiveOverload(session: session, activeDay: activeDay, database: db)
            }
            
            history.append(session)
            
            if let day = activeWorkoutDay {
                markDayComplete(dayName: session.dayName, week: day.week)
            }
            
            saveHistory()
        }
        
        isSessionActive = false
        activeWorkoutDay = nil
        currentSession = nil
        elapsedSeconds = 0
        isTimerPaused = false
        completedWarmups = [:]
        
        clearSessionState() // Clear from UserDefaults
    }
    
    @objc func saveSessionState() {
        guard isSessionActive, let session = currentSession, let day = activeWorkoutDay else { return }
        
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: kSessionActive)
        defaults.set(elapsedSeconds, forKey: kElapsedSeconds)
        defaults.set(isTimerPaused, forKey: kIsTimerPaused)
        
        defaults.set(restTimeRemaining, forKey: kRestTimeRemaining)
        defaults.set(isRestTimerActive, forKey: kIsRestTimerActive)
        defaults.set(isRestTimerPaused, forKey: kIsRestTimerPaused)
        
        defaults.set(Date(), forKey: kLastSavedDate)
        
        if let encodedDay = try? JSONEncoder().encode(day) {
            defaults.set(encodedDay, forKey: kActiveDay)
        }
        if let encodedSession = try? JSONEncoder().encode(session) {
            defaults.set(encodedSession, forKey: kCurrentSession)
        }
        if let encodedWarmups = try? JSONEncoder().encode(completedWarmups) {
            defaults.set(encodedWarmups, forKey: kCompletedWarmups)
        }
    }
    
    func restoreSessionState() {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: kSessionActive) else { return }
        
        if let dayData = defaults.data(forKey: kActiveDay),
           let day = try? JSONDecoder().decode(WorkoutDay.self, from: dayData) {
            self.activeWorkoutDay = day
        }
        
        if let sessionData = defaults.data(forKey: kCurrentSession),
           let session = try? JSONDecoder().decode(CompletedWorkout.self, from: sessionData) {
            self.currentSession = session
        }
        
        if let warmupsData = defaults.data(forKey: kCompletedWarmups),
           let warmups = try? JSONDecoder().decode([UUID: Set<Int>].self, from: warmupsData) {
            self.completedWarmups = warmups
        }
        
        self.isSessionActive = true
        self.isTimerPaused = defaults.bool(forKey: kIsTimerPaused)
        
        let savedSeconds = defaults.integer(forKey: kElapsedSeconds)
        let lastSavedDate = defaults.object(forKey: kLastSavedDate) as? Date ?? Date()
        let timeGap = Int(Date().timeIntervalSince(lastSavedDate))
        
        if !isTimerPaused {
            // SAFEGUARD: 24 Hour check
            if timeGap < 86400 {
                self.elapsedSeconds = savedSeconds + timeGap
                startProgramTimer()
            } else {
                self.elapsedSeconds = savedSeconds
                self.isTimerPaused = true
            }
        } else {
            self.elapsedSeconds = savedSeconds
        }
        
        self.isRestTimerPaused = defaults.bool(forKey: kIsRestTimerPaused)
        let wasRestActive = defaults.bool(forKey: kIsRestTimerActive)
        let savedRestTime = defaults.integer(forKey: kRestTimeRemaining)
        
        if wasRestActive {
            if !isRestTimerPaused {
                let adjustedRestTime = savedRestTime - timeGap
                if adjustedRestTime > 0 {
                    startRestTimer(duration: adjustedRestTime)
                } else {
                    self.isRestTimerActive = false
                    self.restTimeRemaining = 0
                }
            } else {
                self.restTimeRemaining = savedRestTime
                self.isRestTimerActive = true
            }
        }
    }
    
    func clearSessionState() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: kSessionActive)
        defaults.removeObject(forKey: kActiveDay)
        defaults.removeObject(forKey: kCurrentSession)
        defaults.removeObject(forKey: kElapsedSeconds)
        defaults.removeObject(forKey: kIsTimerPaused)
        defaults.removeObject(forKey: kRestTimeRemaining)
        defaults.removeObject(forKey: kIsRestTimerActive)
        defaults.removeObject(forKey: kIsRestTimerPaused)
        defaults.removeObject(forKey: kLastSavedDate)
        defaults.removeObject(forKey: kCompletedWarmups)
    }
    
    private func applyProgressiveOverload(session: CompletedWorkout, activeDay: WorkoutDay, database: ExerciseDatabase) {
        let key = getScheduleKey(week: activeDay.week, dayName: activeDay.name)
        
        let defaults = activeDay.exercises.filter {
            !(removedDefaultExercises[key]?.contains($0.name) ?? false)
        }
        let added = addedExercises[key] ?? []
        let plannedExercises = defaults + added
        
        for planned in plannedExercises {
            guard planned.liftType == .accessory else { continue }
            guard let loggedData = session.exercises.first(where: { $0.name == planned.name }) else { continue }
            if loggedData.sets.count < planned.sets { continue }
            
            let targetRepsStr = getReps(for: planned.name, defaultReps: planned.reps)
            let targetReps = parseTargetReps(targetRepsStr)
            
            guard targetReps > 0 else { continue }
            
            let allSetsMetTarget = loggedData.sets.allSatisfy { setLog in
                let actualReps = Int(setLog.reps.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
                return actualReps >= targetReps
            }
            
            if allSetsMetTarget {
                if let lastSetWeight = loggedData.sets.last?.weight {
                    let newWeight = lastSetWeight + 5.0
                    database.saveWeight(for: planned.name, weight: newWeight)
                }
            }
        }
    }
    
    private func parseTargetReps(_ repString: String) -> Int {
        if repString.contains("-") {
            let parts = repString.components(separatedBy: "-")
            if let last = parts.last, let val = Int(last.trimmingCharacters(in: .whitespaces)) {
                return val
            }
        }
        return Int(repString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0
    }
    
    func deleteWorkout(_ workout: CompletedWorkout) {
        if let index = history.firstIndex(where: { $0.id == workout.id }) {
            history.remove(at: index)
            saveHistory()
        }
    }
    
    // Updates Start and End times
    func updateWorkoutTimes(_ workout: CompletedWorkout, newStart: Date, newEnd: Date) {
        if let index = history.firstIndex(where: { $0.id == workout.id }) {
            history[index].startTime = newStart
            history[index].endTime = newEnd
            history[index].duration = newEnd.timeIntervalSince(newStart)
            saveHistory()
        }
    }
    
    // MARK: - Progression Logic
    func resetProgram() {
        currentWeek = 1
        completedDaysByWeek = [:]
        saveProgression()
    }
    
    func jumpToWeek(_ week: Int) {
        currentWeek = week
        saveProgression()
    }
    
    private func markDayComplete(dayName: String, week: Int) {
        if completedDaysByWeek[week] == nil {
            completedDaysByWeek[week] = []
        }
        
        if let days = completedDaysByWeek[week], !days.contains(dayName) {
            completedDaysByWeek[week]?.append(dayName)
            saveProgression()
            checkWeekCompletion(week: week)
        }
    }
    
    private func checkWeekCompletion(week: Int) {
        if let days = completedDaysByWeek[week], days.count >= 4 {
            if currentWeek == week {
                currentWeek += 1
                saveProgression()
            }
        }
    }
    
    private func saveProgression() {
        UserDefaults.standard.set(currentWeek, forKey: "current_week")
        if let encoded = try? JSONEncoder().encode(completedDaysByWeek) {
            UserDefaults.standard.set(encoded, forKey: "completed_days_by_week_dict")
        }
    }
    
    private func loadProgression() {
        let savedWeek = UserDefaults.standard.integer(forKey: "current_week")
        currentWeek = savedWeek > 0 ? savedWeek : 1
        
        if let data = UserDefaults.standard.data(forKey: "completed_days_by_week_dict"),
           let decoded = try? JSONDecoder().decode([Int: [String]].self, from: data) {
            completedDaysByWeek = decoded
        }
    }
    
    // MARK: - Schedule Modification (UPDATED: RESTORED WEEK-SPECIFIC LOGIC)
    func addExerciseToSchedule(day: WorkoutDay, exercise: Exercise) {
        let key = getScheduleKey(week: day.week, dayName: day.name)
        if addedExercises[key] == nil { addedExercises[key] = [] }
        addedExercises[key]?.append(exercise)
        saveScheduleModifications()
    }
    
    func removeExerciseFromSchedule(day: WorkoutDay, exercise: Exercise) {
        let key = getScheduleKey(week: day.week, dayName: day.name)
        
        if var addedList = addedExercises[key], let index = addedList.firstIndex(where: { $0.id == exercise.id }) {
            addedList.remove(at: index)
            addedExercises[key] = addedList
            saveScheduleModifications()
            return
        }
        
        if removedDefaultExercises[key] == nil { removedDefaultExercises[key] = [] }
        removedDefaultExercises[key]?.append(exercise.name)
        saveScheduleModifications()
    }
    
    private func saveScheduleModifications() {
        if let encoded = try? JSONEncoder().encode(addedExercises) {
            UserDefaults.standard.set(encoded, forKey: "added_exercises_schedule")
        }
        if let encodedRemoved = try? JSONEncoder().encode(removedDefaultExercises) {
            UserDefaults.standard.set(encodedRemoved, forKey: "removed_exercises_schedule")
        }
        if let encodedReps = try? JSONEncoder().encode(overriddenReps) {
            UserDefaults.standard.set(encodedReps, forKey: "overridden_reps_schedule")
        }
        if let encodedEq = try? JSONEncoder().encode(overriddenEquipment) {
            UserDefaults.standard.set(encodedEq, forKey: "overridden_equipment_schedule")
        }
    }
    
    private func loadScheduleModifications() {
        if let data = UserDefaults.standard.data(forKey: "added_exercises_schedule"),
           let decoded = try? JSONDecoder().decode([String: [Exercise]].self, from: data) {
            addedExercises = decoded
        }
        if let dataRemoved = UserDefaults.standard.data(forKey: "removed_exercises_schedule"),
           let decodedRemoved = try? JSONDecoder().decode([String: [String]].self, from: dataRemoved) {
            removedDefaultExercises = decodedRemoved
        }
        if let dataReps = UserDefaults.standard.data(forKey: "overridden_reps_schedule"),
           let decodedReps = try? JSONDecoder().decode([String: String].self, from: dataReps) {
            overriddenReps = decodedReps
        }
        if let dataEq = UserDefaults.standard.data(forKey: "overridden_equipment_schedule"),
           let decodedEq = try? JSONDecoder().decode([String: Equipment].self, from: dataEq) {
            overriddenEquipment = decodedEq
        }
    }
    
    // MARK: - Logging
    func logSet(exerciseId: UUID, exerciseName: String, setIndex: Int, weight: Double, reps: String) {
        guard var session = currentSession else { return }
        
        if let existingIndex = session.exercises.firstIndex(where: { $0.name == exerciseName }) {
            let newSet = CompletedSet(setNumber: setIndex + 1, reps: reps, weight: weight, isCompleted: true, timestamp: Date())
            session.exercises[existingIndex].sets.append(newSet)
        } else {
            let newSet = CompletedSet(setNumber: setIndex + 1, reps: reps, weight: weight, isCompleted: true, timestamp: Date())
            let completedExercise = CompletedExercise(exerciseId: exerciseId, name: exerciseName, sets: [newSet])
            session.exercises.append(completedExercise)
        }
        
        currentSession = session
        
        if isTimerPaused {
            isTimerPaused = false
        }
        saveSessionState()
    }
    
    private func startProgramTimer() {
        programTimer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if !self.isTimerPaused {
                    self.elapsedSeconds += 1
                }
            }
    }
    
    private func stopProgramTimer() {
        programTimer?.cancel()
        programTimer = nil
    }
    
    func togglePause() {
        isTimerPaused.toggle()
        saveSessionState()
    }
    
    private func saveHistory() {
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: "workout_history")
        }
    }
    
    private func loadHistory() {
        if let data = UserDefaults.standard.data(forKey: "workout_history"),
           let decoded = try? JSONDecoder().decode([CompletedWorkout].self, from: data) {
            history = decoded
        }
    }
    
    var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
