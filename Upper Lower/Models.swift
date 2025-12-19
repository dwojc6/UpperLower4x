//
//  Models.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import Foundation

// MARK: - Equipment Enum
enum Equipment: String, Codable, CaseIterable, Equatable, Sendable {
    case barbell = "Barbell (45 lbs)"
    case barbell25 = "Barbell (25 lbs)"
    case smithMachine = "Smith Machine (15 lbs)"
    case machine = "Machine"
    case cable = "Cable"
    case bodyweight = "Bodyweight"
    case dumbbell = "Dumbbell"
    case other = "Other"
    
    var baseWeight: Double {
        switch self {
        case .barbell: return 45.0
        case .barbell25: return 25.0
        case .smithMachine: return 15.0
        default: return 0.0
        }
    }
    
    var iconName: String {
        switch self {
        case .barbell, .barbell25: return "scalemass.fill"
        case .smithMachine: return "building.columns.fill"
        case .machine: return "gearshape.2.fill"
        case .cable: return "arrow.triangle.2.circlepath"
        case .bodyweight: return "figure.walk"
        case .dumbbell: return "dumbbell.fill"
        default: return "questionmark.circle"
        }
    }
    
    // Calculates plates required per side
    func getPlateBreakdown(for totalWeight: Double) -> String? {
        guard self == .barbell || self == .barbell25 || self == .smithMachine else { return nil }
        
        if totalWeight <= baseWeight { return "Empty Bar" }
        
        var remainingWeight = (totalWeight - baseWeight) / 2.0
        let plates: [Double] = [45, 35, 25, 10, 5, 2.5]
        var breakdown: [String] = []
        
        for plate in plates {
            let count = Int(remainingWeight / plate)
            if count > 0 {
                let plateName = String(format: "%g", plate)
                breakdown.append("\(count)x\(plateName)")
                remainingWeight -= Double(count) * plate
                remainingWeight = (remainingWeight * 10).rounded() / 10
            }
        }
        
        return breakdown.isEmpty ? nil : breakdown.joined(separator: ", ")
    }
}

// MARK: - LiftType Enum
enum LiftType: String, Codable, Equatable, Sendable {
    case squat = "Back Squat"
    case bench = "Bench Press"
    case deadlift = "Deadlift"
    case accessory = "Accessory"
}

// MARK: - Exercise Struct
struct Exercise: Identifiable, Codable, Equatable, Sendable {
    var id = UUID()
    let name: String
    let sets: Int
    let reps: String
    let liftType: LiftType
    let percentageOf1RM: Double?
    let rpeOrNotes: String
    var equipment: Equipment = .other
    
    func targetWeight(userProfile: UserProfile) -> Double? {
        guard let percent = percentageOf1RM else { return nil }
        
        switch liftType {
        case .squat: return (userProfile.squatMax * percent).rounded(to: 5.0)
        case .bench: return (userProfile.benchMax * percent).rounded(to: 5.0)
        case .deadlift: return (userProfile.deadliftMax * percent).rounded(to: 5.0)
        default: return nil
        }
    }
    
    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.sets == rhs.sets &&
               lhs.reps == rhs.reps &&
               lhs.liftType == rhs.liftType &&
               lhs.percentageOf1RM == rhs.percentageOf1RM &&
               lhs.rpeOrNotes == rhs.rpeOrNotes &&
               lhs.equipment == rhs.equipment
    }
}

// MARK: - WorkoutDay Struct
struct WorkoutDay: Identifiable, Codable, Equatable, Sendable {
    var id = UUID()
    let name: String
    let week: Int
    var exercises: [Exercise]
}

// MARK: - UserProfile Struct
struct UserProfile: Codable, Sendable {
    var squatMax: Double
    var benchMax: Double
    var deadliftMax: Double
}

// MARK: - History Models

struct CompletedSet: Identifiable, Codable, Sendable {
    var id = UUID()
    let setNumber: Int
    let reps: String
    let weight: Double
    let isCompleted: Bool
    let timestamp: Date
}

struct CompletedExercise: Identifiable, Codable, Sendable {
    var id = UUID()
    let exerciseId: UUID
    let name: String
    var sets: [CompletedSet]
}

struct CompletedWorkout: Identifiable, Codable, Sendable {
    var id = UUID()
    let dayName: String
    var week: Int?
    var startTime: Date
    var endTime: Date?
    var exercises: [CompletedExercise]
    var duration: TimeInterval = 0
}

extension Double {
    func rounded(to interval: Double) -> Double {
        return (self / interval).rounded(.down) * interval
    }
}

// MARK: - Backup Model
struct BackupData: Codable, Sendable {
    // WorkoutManager Data
    let history: [CompletedWorkout]
    let supersets: [String: [Set<String>]]
    let exerciseOrder: [String: [String]]
    let currentWeek: Int
    let completedDaysByWeek: [Int: [String]]
    let addedExercises: [String: [Exercise]]
    let removedDefaultExercises: [String: [String]]
    let overriddenReps: [String: String]
    let overriddenEquipment: [String: Equipment]
    
    // ExerciseDatabase Data
    let savedWeights: [String: Double]
    let customExercises: [String]
    
    // User Profile Data
    let squatMax: Double
    let benchMax: Double
    let deadliftMax: Double
    let hasOnboarded: Bool

    // MARK: - Manual Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case history, supersets, exerciseOrder, currentWeek, completedDaysByWeek
        case addedExercises, removedDefaultExercises, overriddenReps, overriddenEquipment
        case savedWeights, customExercises
        case squatMax, benchMax, deadliftMax, hasOnboarded
    }
    
    // Explicitly nonisolated to satisfy Swift 6 strict concurrency checks in SettingsView
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        history = try container.decode([CompletedWorkout].self, forKey: .history)
        supersets = try container.decode([String: [Set<String>]].self, forKey: .supersets)
        exerciseOrder = try container.decode([String: [String]].self, forKey: .exerciseOrder)
        currentWeek = try container.decode(Int.self, forKey: .currentWeek)
        completedDaysByWeek = try container.decode([Int: [String]].self, forKey: .completedDaysByWeek)
        addedExercises = try container.decode([String: [Exercise]].self, forKey: .addedExercises)
        removedDefaultExercises = try container.decode([String: [String]].self, forKey: .removedDefaultExercises)
        overriddenReps = try container.decode([String: String].self, forKey: .overriddenReps)
        overriddenEquipment = try container.decode([String: Equipment].self, forKey: .overriddenEquipment)
        savedWeights = try container.decode([String: Double].self, forKey: .savedWeights)
        customExercises = try container.decode([String].self, forKey: .customExercises)
        squatMax = try container.decode(Double.self, forKey: .squatMax)
        benchMax = try container.decode(Double.self, forKey: .benchMax)
        deadliftMax = try container.decode(Double.self, forKey: .deadliftMax)
        hasOnboarded = try container.decode(Bool.self, forKey: .hasOnboarded)
    }
    
    // Explicitly nonisolated to satisfy Swift 6 strict concurrency checks in SettingsView
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(history, forKey: .history)
        try container.encode(supersets, forKey: .supersets)
        try container.encode(exerciseOrder, forKey: .exerciseOrder)
        try container.encode(currentWeek, forKey: .currentWeek)
        try container.encode(completedDaysByWeek, forKey: .completedDaysByWeek)
        try container.encode(addedExercises, forKey: .addedExercises)
        try container.encode(removedDefaultExercises, forKey: .removedDefaultExercises)
        try container.encode(overriddenReps, forKey: .overriddenReps)
        try container.encode(overriddenEquipment, forKey: .overriddenEquipment)
        try container.encode(savedWeights, forKey: .savedWeights)
        try container.encode(customExercises, forKey: .customExercises)
        try container.encode(squatMax, forKey: .squatMax)
        try container.encode(benchMax, forKey: .benchMax)
        try container.encode(deadliftMax, forKey: .deadliftMax)
        try container.encode(hasOnboarded, forKey: .hasOnboarded)
    }
    
    // Memberwise initializer (required because we added a custom init(from:))
    init(history: [CompletedWorkout], supersets: [String: [Set<String>]], exerciseOrder: [String: [String]], currentWeek: Int, completedDaysByWeek: [Int: [String]], addedExercises: [String: [Exercise]], removedDefaultExercises: [String: [String]], overriddenReps: [String: String], overriddenEquipment: [String: Equipment], savedWeights: [String: Double], customExercises: [String], squatMax: Double, benchMax: Double, deadliftMax: Double, hasOnboarded: Bool) {
        self.history = history
        self.supersets = supersets
        self.exerciseOrder = exerciseOrder
        self.currentWeek = currentWeek
        self.completedDaysByWeek = completedDaysByWeek
        self.addedExercises = addedExercises
        self.removedDefaultExercises = removedDefaultExercises
        self.overriddenReps = overriddenReps
        self.overriddenEquipment = overriddenEquipment
        self.savedWeights = savedWeights
        self.customExercises = customExercises
        self.squatMax = squatMax
        self.benchMax = benchMax
        self.deadliftMax = deadliftMax
        self.hasOnboarded = hasOnboarded
    }
}
