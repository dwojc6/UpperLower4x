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
    
    func addCustomExercise(name: String) {
        if !customExercises.contains(name) {
            customExercises.append(name)
            persist()
        }
    }
    
    var allExerciseNames: [String] {
        var programExercises: Set<String> = []
        for week in 1...9 {
            let days = ProgramData.shared.getDays(forWeek: week)
            let names = days.flatMap { $0.exercises }.map { $0.name }
            programExercises.formUnion(names)
        }
        let all = programExercises.union(customExercises)
        return Array(all).sorted()
    }
    
    private func persist() {
        if let encoded = try? JSONEncoder().encode(savedWeights) {
            UserDefaults.standard.set(encoded, forKey: "exercise_database_weights")
        }
        UserDefaults.standard.set(customExercises, forKey: "exercise_database_custom")
    }
    
    private func loadData() {
        if let data = UserDefaults.standard.data(forKey: "exercise_database_weights"),
           let decoded = try? JSONDecoder().decode([String: Double].self, from: data) {
            savedWeights = decoded
        }
        if let custom = UserDefaults.standard.array(forKey: "exercise_database_custom") as? [String] {
            customExercises = custom
        }
    }
}
