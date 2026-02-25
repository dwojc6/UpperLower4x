//
//  Models.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import Foundation

// MARK: - Equipment Enum
enum Equipment: String, Codable, CaseIterable, Equatable, Sendable {
    case barbell = "Barbell"
    case machine = "Machine"
    case plateLoaded = "Plate Loaded"
    case cable = "Cable"
    case kettlebell = "Kettlebell"
    case dumbbell = "Dumbbell"
    case bodyweight = "Body Weight"

    static var allCases: [Equipment] {
        [
            .barbell,
            .machine,
            .plateLoaded,
            .cable,
            .kettlebell,
            .dumbbell,
            .bodyweight
        ]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        switch raw {
        case Equipment.barbell.rawValue, "Barbell (45 lbs)", "Barbell (25 lbs)":
            self = .barbell
        case Equipment.machine.rawValue, "Smith Machine (15 lbs)":
            self = .machine
        case Equipment.plateLoaded.rawValue:
            self = .plateLoaded
        case Equipment.cable.rawValue:
            self = .cable
        case Equipment.kettlebell.rawValue:
            self = .kettlebell
        case Equipment.dumbbell.rawValue:
            self = .dumbbell
        case Equipment.bodyweight.rawValue, "Bodyweight":
            self = .bodyweight
        case "Other":
            self = .plateLoaded
        default:
            self = .machine
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
    
    var baseWeight: Double {
        switch self {
        case .barbell: return 45.0
        default: return 0.0
        }
    }
    
    var iconName: String {
        switch self {
        case .barbell: return "scalemass.fill"
        case .machine: return "gearshape.2.fill"
        case .plateLoaded: return "rectangle.stack.fill"
        case .cable: return "arrow.triangle.2.circlepath"
        case .bodyweight: return "figure.walk"
        case .kettlebell: return "k.circle.fill"
        case .dumbbell: return "dumbbell.fill"
        }
    }
    
    // Calculates plates required per side
    func getPlateBreakdown(for totalWeight: Double, baseWeightOverride: Double? = nil) -> String? {
        let base: Double
        let emptyLabel: String
        switch self {
        case .barbell:
            base = baseWeightOverride ?? baseWeight
            emptyLabel = "Empty Bar"
        case .plateLoaded:
            base = 0
            emptyLabel = "No Plates"
        default:
            return nil
        }

        if totalWeight <= base { return emptyLabel }
        
        var remainingWeight = (totalWeight - base) / 2.0
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
    var rpeOrNotes: String
    var equipment: Equipment = .machine
    
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
    // This was already there
    func rounded(to interval: Double) -> Double {
        return (self / interval).rounded(.toNearestOrAwayFromZero) * interval
    }
    
    // NEW: Add this property inside the same bracket
    var formattedWeight: String {
        let isInteger = self.truncatingRemainder(dividingBy: 1) == 0
        return isInteger ? String(format: "%.0f", self) : String(format: "%.1f", self)
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
    let overriddenBarbellWeights: [String: Double]
    let overriddenProgressionAmounts: [String: Double]
    let overriddenRestTimerDurations: [String: Int]
    
    // ExerciseDatabase Data
    let savedWeights: [String: Double]
    let customExercises: [String]
    let hiddenExercises: [String]
    
    // User Profile Data
    let squatMax: Double
    let benchMax: Double
    let deadliftMax: Double
    let hasOnboarded: Bool

    // MARK: - Manual Codable Implementation
    
    enum CodingKeys: String, CodingKey {
        case history, supersets, exerciseOrder, currentWeek, completedDaysByWeek
        case addedExercises, removedDefaultExercises, overriddenReps, overriddenEquipment, overriddenBarbellWeights, overriddenProgressionAmounts, overriddenRestTimerDurations
        case savedWeights, customExercises, hiddenExercises
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
        overriddenBarbellWeights = try container.decodeIfPresent([String: Double].self, forKey: .overriddenBarbellWeights) ?? [:]
        overriddenProgressionAmounts = try container.decodeIfPresent([String: Double].self, forKey: .overriddenProgressionAmounts) ?? [:]
        overriddenRestTimerDurations = try container.decodeIfPresent([String: Int].self, forKey: .overriddenRestTimerDurations) ?? [:]
        savedWeights = try container.decode([String: Double].self, forKey: .savedWeights)
        customExercises = try container.decode([String].self, forKey: .customExercises)
        hiddenExercises = try container.decodeIfPresent([String].self, forKey: .hiddenExercises) ?? []
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
        try container.encode(overriddenBarbellWeights, forKey: .overriddenBarbellWeights)
        try container.encode(overriddenProgressionAmounts, forKey: .overriddenProgressionAmounts)
        try container.encode(overriddenRestTimerDurations, forKey: .overriddenRestTimerDurations)
        try container.encode(savedWeights, forKey: .savedWeights)
        try container.encode(customExercises, forKey: .customExercises)
        try container.encode(hiddenExercises, forKey: .hiddenExercises)
        try container.encode(squatMax, forKey: .squatMax)
        try container.encode(benchMax, forKey: .benchMax)
        try container.encode(deadliftMax, forKey: .deadliftMax)
        try container.encode(hasOnboarded, forKey: .hasOnboarded)
    }
    
    // Memberwise initializer (required because we added a custom init(from:))
    init(history: [CompletedWorkout], supersets: [String: [Set<String>]], exerciseOrder: [String: [String]], currentWeek: Int, completedDaysByWeek: [Int: [String]], addedExercises: [String: [Exercise]], removedDefaultExercises: [String: [String]], overriddenReps: [String: String], overriddenEquipment: [String: Equipment], overriddenBarbellWeights: [String: Double], overriddenProgressionAmounts: [String: Double], overriddenRestTimerDurations: [String: Int], savedWeights: [String: Double], customExercises: [String], hiddenExercises: [String], squatMax: Double, benchMax: Double, deadliftMax: Double, hasOnboarded: Bool) {
        self.history = history
        self.supersets = supersets
        self.exerciseOrder = exerciseOrder
        self.currentWeek = currentWeek
        self.completedDaysByWeek = completedDaysByWeek
        self.addedExercises = addedExercises
        self.removedDefaultExercises = removedDefaultExercises
        self.overriddenReps = overriddenReps
        self.overriddenEquipment = overriddenEquipment
        self.overriddenBarbellWeights = overriddenBarbellWeights
        self.overriddenProgressionAmounts = overriddenProgressionAmounts
        self.overriddenRestTimerDurations = overriddenRestTimerDurations
        self.savedWeights = savedWeights
        self.customExercises = customExercises
        self.hiddenExercises = hiddenExercises
        self.squatMax = squatMax
        self.benchMax = benchMax
        self.deadliftMax = deadliftMax
        self.hasOnboarded = hasOnboarded
    }
}
