//
//  OnboardingView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct OnboardingView: View {
    @Binding var squat: String
    @Binding var bench: String
    @Binding var deadlift: String
    var onSave: () -> Void
    
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var database: ExerciseDatabase
    
    @State private var showFileImporter = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    @ScaledMetric var buttonHeight: CGFloat = 55
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("SETUP PROGRAM")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .padding(.top, 60)
                        .padding(.bottom, 40)
                    
                    Text("Enter your 1 Rep Max (Lbs)")
                        .foregroundColor(.gray)
                    
                    VStack(spacing: 15) {
                        inputField(title: "Squat", text: $squat)
                        inputField(title: "Bench", text: $bench)
                        inputField(title: "Deadlift", text: $deadlift)
                    }
                    .padding(.horizontal)
                    
                    Button(action: onSave) {
                        Text("CREATE PROGRAM")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                    .disabled(squat.isEmpty || bench.isEmpty || deadlift.isEmpty)
                    .opacity(squat.isEmpty || bench.isEmpty || deadlift.isEmpty ? 0.6 : 1.0)
                    
                    Button(action: { showFileImporter = true }) {
                        Text("Import Backup")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                            .padding()
                    }
                    .padding(.top, 10)
                    
                    Spacer()
                }
                .padding()
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .preferredColorScheme(.dark)
        // Native Document Picker Sheet
        .sheet(isPresented: $showFileImporter) {
            DocumentPicker(onPick: { url in
                showFileImporter = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    importBackup(from: url)
                }
            }, onError: { error in
                alertMessage = "Import failed: \(error.localizedDescription)"
                showAlert = true
            })
        }
        .alert("Backup Import", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    func inputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading) {
            Text(title.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            TextField("0", text: text)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .foregroundColor(.white)
        }
    }
    
    func importBackup(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            let coordinator = NSFileCoordinator()
            var fileError: NSError?
            
            coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: &fileError) { safeURL in
                do {
                    let data = try Data(contentsOf: safeURL)
                    let backup = try JSONDecoder().decode(BackupData.self, from: data)
                    
                    DispatchQueue.main.async {
                        saveBackupData(backup)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.alertMessage = "Failed to read file: \(error.localizedDescription)"
                        self.showAlert = true
                    }
                }
            }
            
            if let error = fileError {
                DispatchQueue.main.async {
                    self.alertMessage = "File access error: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }
    
    func saveBackupData(_ backup: BackupData) {
        // 1. Save Data to UserDefaults
        if let encodedHistory = try? JSONEncoder().encode(backup.history) {
            UserDefaults.standard.set(encodedHistory, forKey: "workout_history")
        }
        if let encodedSupersets = try? JSONEncoder().encode(backup.supersets) {
            UserDefaults.standard.set(encodedSupersets, forKey: "workout_supersets_v2")
        }
        if let encodedOrder = try? JSONEncoder().encode(backup.exerciseOrder) {
            UserDefaults.standard.set(encodedOrder, forKey: "workout_exercise_order")
        }
        
        UserDefaults.standard.set(backup.currentWeek, forKey: "current_week")
        if let encodedDays = try? JSONEncoder().encode(backup.completedDaysByWeek) {
            UserDefaults.standard.set(encodedDays, forKey: "completed_days_by_week_dict")
        }
        if let encodedAdded = try? JSONEncoder().encode(backup.addedExercises) {
            UserDefaults.standard.set(encodedAdded, forKey: "added_exercises_schedule")
        }
        if let encodedRemoved = try? JSONEncoder().encode(backup.removedDefaultExercises) {
            UserDefaults.standard.set(encodedRemoved, forKey: "removed_exercises_schedule")
        }
        if let encodedReps = try? JSONEncoder().encode(backup.overriddenReps) {
            UserDefaults.standard.set(encodedReps, forKey: "overridden_reps_schedule")
        }
        if let encodedEq = try? JSONEncoder().encode(backup.overriddenEquipment) {
            UserDefaults.standard.set(encodedEq, forKey: "overridden_equipment_schedule")
        }
        if let encodedWeights = try? JSONEncoder().encode(backup.savedWeights) {
            UserDefaults.standard.set(encodedWeights, forKey: "exercise_database_weights")
        }
        UserDefaults.standard.set(backup.customExercises, forKey: "exercise_database_custom")
        
        // 2. CRITICAL FIX: Update the Bindings!
        // This ensures that when onSave() is called, it reads these values instead of empty strings
        self.squat = String(Int(backup.squatMax))
        self.bench = String(Int(backup.benchMax))
        self.deadlift = String(Int(backup.deadliftMax))
        
        // Also save directly to UserDefaults just in case
        UserDefaults.standard.set(backup.squatMax, forKey: "squatMax")
        UserDefaults.standard.set(backup.benchMax, forKey: "benchMax")
        UserDefaults.standard.set(backup.deadliftMax, forKey: "deadliftMax")
        
        // 3. Reload Managers
        workoutManager.reloadAllData()
        database.reload()
        
        // 4. Trigger Transition
        UserDefaults.standard.set(true, forKey: "hasOnboarded")
        onSave()
    }
}
