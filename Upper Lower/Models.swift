//
//  Models.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import Foundation

// MARK: - Equipment Enum
enum Equipment: String, Codable, CaseIterable, Equatable {
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

// Represents the types of main lifts for 1RM calculations
enum LiftType: String, Codable, Equatable {
    case squat = "Back Squat"
    case bench = "Bench Press"
    case deadlift = "Deadlift"
    case accessory = "Accessory"
}

struct Exercise: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let sets: Int
    let reps: String
    let liftType: LiftType
    let percentageOf1RM: Double?
    let rpeOrNotes: String
    var equipment: Equipment = .other
    
    // Calculated weight based on user's 1RM
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

struct WorkoutDay: Identifiable, Codable, Equatable {
    var id = UUID()
    let name: String
    let week: Int
    var exercises: [Exercise]
}

struct UserProfile: Codable {
    var squatMax: Double
    var benchMax: Double
    var deadliftMax: Double
}

// MARK: - History Models

struct CompletedSet: Identifiable, Codable {
    var id = UUID()
    let setNumber: Int
    let reps: String
    let weight: Double
    let isCompleted: Bool
    let timestamp: Date
}

struct CompletedExercise: Identifiable, Codable {
    var id = UUID()
    let exerciseId: UUID
    let name: String
    var sets: [CompletedSet]
}

struct CompletedWorkout: Identifiable, Codable {
    var id = UUID()
    let dayName: String
    var week: Int?
    var startTime: Date      // CHANGED: 'let' -> 'var'
    var endTime: Date?       // CHANGED: 'let' -> 'var' (was already var in your previous file, but ensuring consistency)
    var exercises: [CompletedExercise]
    var duration: TimeInterval = 0
}

extension Double {
    func rounded(to interval: Double) -> Double {
        return (self / interval).rounded(.down) * interval
    }
}
