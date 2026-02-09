//
//  ExerciseDatabase.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import Foundation
import Combine

class ExerciseDatabase: ObservableObject {
    @Published var savedWeights: [String: Double] = [:]
    @Published var customExercises: [String] = []
    @Published var hiddenExercises: [String] = []
    
    init() {
        loadData()
    }
    
    // MARK: - API
    
    // NEW: Public function to reload data
    func reload() {
        loadData()
    }
    
    func getWeight(for name: String) -> Double? {
        return savedWeights[name]
    }
    
    func saveWeight(for name: String, weight: Double) {
        savedWeights[name] = weight
        persist()
    }

    func clearWeight(for name: String) {
        if savedWeights.removeValue(forKey: name) != nil {
            persist()
        }
    }

    func clearPercentBasedWeights() {
        let percentNames = percentBasedExerciseNames()
        guard !percentNames.isEmpty else { return }
        var didRemove = false
        for name in percentNames where savedWeights[name] != nil {
            savedWeights.removeValue(forKey: name)
            didRemove = true
        }
        if didRemove {
            persist()
        }
    }
    
    func addCustomExercise(name: String) {
        if !customExercises.contains(name) {
            customExercises.append(name)
            persist()
        }
    }

    func removeCustomExercise(name: String) {
        if let index = customExercises.firstIndex(of: name) {
            customExercises.remove(at: index)
            persist()
        }
    }

    func hideExercise(name: String) {
        if !hiddenExercises.contains(name) {
            hiddenExercises.append(name)
            persist()
        }
    }

    func unhideExercise(name: String) {
        if let index = hiddenExercises.firstIndex(of: name) {
            hiddenExercises.remove(at: index)
            persist()
        }
    }

    func isHidden(name: String) -> Bool {
        hiddenExercises.contains(name)
    }
    
    var allExerciseNames: [String] {
        var programExercises: Set<String> = []
        for week in 1...9 {
            let days = ProgramData.shared.getDays(forWeek: week)
            let names = days.flatMap { $0.exercises }.map { $0.name }
            programExercises.formUnion(names)
        }
        let all = programExercises.union(customExercises)
        let visible = all.subtracting(hiddenExercises)
        return Array(visible).sorted()
    }
    
    private func persist() {
        if let encoded = try? JSONEncoder().encode(savedWeights) {
            UserDefaults.standard.set(encoded, forKey: "exercise_database_weights")
        }
        UserDefaults.standard.set(customExercises, forKey: "exercise_database_custom")
        UserDefaults.standard.set(hiddenExercises, forKey: "exercise_database_hidden")
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "exercise_database_weights"),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            savedWeights = decoded
        }
        if let custom = UserDefaults.standard.array(forKey: "exercise_database_custom") as? [String] {
            customExercises = custom
        }
        if let hidden = UserDefaults.standard.array(forKey: "exercise_database_hidden") as? [String] {
            hiddenExercises = hidden
        }
    }

    private func percentBasedExerciseNames() -> Set<String> {
        var names = Set<String>()
        for week in 1...9 {
            let days = ProgramData.shared.getDays(forWeek: week)
            for exercise in days.flatMap({ $0.exercises }) where exercise.percentageOf1RM != nil {
                names.insert(exercise.name)
            }
        }
        return names
    }
}
