//
//  SettingsView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 12/8/25.
//

import SwiftUI
import UniformTypeIdentifiers
import UIKit

// MARK: - JSON Document Helper
struct BackupDocument: FileDocument {
    nonisolated(unsafe) static var readableContentTypes: [UTType] { [.json] }
    
    var data: BackupData
    
    init(data: BackupData) {
        self.data = data
    }
    
    init(configuration: ReadConfiguration) throws {
        let decoder = JSONDecoder()
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.data = try decoder.decode(BackupData.self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(self.data)
        return FileWrapper(regularFileWithContents: data)
    }
}

// MARK: - CSV Document Helper
struct CompletedLiftsCSVDocument: FileDocument {
    nonisolated(unsafe) static var readableContentTypes: [UTType] {
        [UTType(filenameExtension: "csv") ?? .plainText]
    }

    let csvText: String

    init(history: [CompletedWorkout]) {
        self.csvText = Self.makeCSV(from: history)
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let csvText = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.csvText = csvText
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(csvText.utf8))
    }

    static func hasCompletedLifts(in history: [CompletedWorkout]) -> Bool {
        history.contains { workout in
            workout.exercises.contains { exercise in
                exercise.sets.contains(where: \.isCompleted)
            }
        }
    }

    private static func makeCSV(from history: [CompletedWorkout]) -> String {
        let headers = [
            "session_date",
            "session_start_time",
            "session_end_time",
            "day_name",
            "week",
            "exercise_name",
            "set_number",
            "reps",
            "weight_lbs",
            "logged_at"
        ]

        var lines = [headers.joined(separator: ",")]
        let sortedHistory = history.sorted { $0.startTime < $1.startTime }

        for workout in sortedHistory {
            let sessionDate = csvDateFormatter.string(from: workout.startTime)
            let sessionStart = csvTimeFormatter.string(from: workout.startTime)
            let sessionEnd = workout.endTime.map { csvTimeFormatter.string(from: $0) } ?? ""
            let week = workout.week.map(String.init) ?? ""

            for exercise in workout.exercises {
                let completedSets = exercise.sets
                    .filter(\.isCompleted)
                    .sorted { lhs, rhs in
                        if lhs.setNumber != rhs.setNumber {
                            return lhs.setNumber < rhs.setNumber
                        }
                        return lhs.timestamp < rhs.timestamp
                    }

                for set in completedSets {
                    let fields = [
                        sessionDate,
                        sessionStart,
                        sessionEnd,
                        workout.dayName,
                        week,
                        exercise.name,
                        String(set.setNumber),
                        set.reps,
                        set.weight.formattedWeight,
                        csvDateTimeFormatter.string(from: set.timestamp)
                    ]

                    lines.append(fields.map(escapeCSVField).joined(separator: ","))
                }
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func escapeCSVField(_ value: String) -> String {
        let escapedValue = value.replacingOccurrences(of: "\"", with: "\"\"")
        if escapedValue.contains(",") || escapedValue.contains("\"") || escapedValue.contains("\n") {
            return "\"\(escapedValue)\""
        }
        return escapedValue
    }

    private static let csvDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let csvTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private static let csvDateTimeFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .current
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}

// MARK: - Settings View
struct SettingsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var database: ExerciseDatabase
    @Environment(\.dismiss) var dismiss
    
    // AppStorage access for manual backup/restore
    @AppStorage("squatMax") var squatMax: Double = 0.0
    @AppStorage("benchMax") var benchMax: Double = 0.0
    @AppStorage("deadliftMax") var deadliftMax: Double = 0.0
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    @State private var showFileExporter = false
    @State private var showCSVExporter = false
    @State private var showFileImporter = false
    @State private var backupDocument: BackupDocument?
    @State private var completedLiftsDocument: CompletedLiftsCSVDocument?
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isImporting = false

    var appVersionText: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "Unknown"
        return "\(version)"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                List {
                    Section(header: Text("Data Management").foregroundColor(.secondary)) {
                        Button(action: prepareExport) {
                            Label("Export Backup", systemImage: "square.and.arrow.up")
                                .foregroundColor(.primary)
                        }

                        Button(action: prepareCompletedLiftsExport) {
                            Label("Export Completed Lifts", systemImage: "tablecells")
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: { showFileImporter = true }) {
                            HStack {
                                Label("Import Backup", systemImage: "square.and.arrow.down")
                                    .foregroundColor(.primary)
                                if isImporting {
                                    Spacer()
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isImporting)
                    }
                    .listRowBackground(Color(UIColor.systemGray6))
                    
                    Section {
                        HStack {
                            Spacer()
                            VStack(spacing: 8) {
                                Text("Upper Lower 4x")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Developed by Slowie")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.medium)
                                Text("Version \(appVersionText)")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            // EXPORT HANDLER
            .fileExporter(
                isPresented: $showFileExporter,
                document: backupDocument,
                contentType: .json,
                defaultFilename: "UpperLower_Backup_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-"))"
            ) { result in
                switch result {
                case .success(let url):
                    print("Saved to \(url)")
                case .failure(let error):
                    alertMessage = "Export failed: \(error.localizedDescription)"
                    showAlert = true
                }
            }
            .fileExporter(
                isPresented: $showCSVExporter,
                document: completedLiftsDocument,
                contentType: UTType(filenameExtension: "csv") ?? .plainText,
                defaultFilename: "UpperLower_CompletedLifts_\(Date().formatted(date: .numeric, time: .omitted).replacingOccurrences(of: "/", with: "-"))"
            ) { result in
                switch result {
                case .success(let url):
                    print("Saved CSV to \(url)")
                case .failure(let error):
                    alertMessage = "CSV export failed: \(error.localizedDescription)"
                    showAlert = true
                }
            }
            // IMPORT HANDLER
            .sheet(isPresented: $showFileImporter) {
                DocumentPicker(onPick: { url in
                    importBackup(from: url)
                }, onError: { error in
                    alertMessage = "Import failed: \(error.localizedDescription)"
                    showAlert = true
                })
            }
            .alert("Data Management", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Logic
    
    func prepareExport() {
        let backup = BackupData(
            history: workoutManager.history,
            supersets: workoutManager.supersets,
            exerciseOrder: workoutManager.exerciseOrder,
            currentWeek: workoutManager.currentWeek,
            completedDaysByWeek: workoutManager.completedDaysByWeek,
            addedExercises: workoutManager.addedExercises,
            removedDefaultExercises: workoutManager.removedDefaultExercises,
            overriddenReps: workoutManager.overriddenReps,
            overriddenEquipment: workoutManager.overriddenEquipment,
            overriddenBarbellWeights: workoutManager.overriddenBarbellWeights,
            overriddenProgressionAmounts: workoutManager.overriddenProgressionAmounts,
            overriddenRestTimerDurations: workoutManager.overriddenRestTimerDurations,
            savedWeights: database.savedWeights,
            customExercises: database.customExercises,
            hiddenExercises: database.hiddenExercises,
            squatMax: squatMax,
            benchMax: benchMax,
            deadliftMax: deadliftMax,
            hasOnboarded: hasOnboarded
        )
        
        self.backupDocument = BackupDocument(data: backup)
        self.showFileExporter = true
    }

    func prepareCompletedLiftsExport() {
        guard CompletedLiftsCSVDocument.hasCompletedLifts(in: workoutManager.history) else {
            alertMessage = "There are no completed lifts in your history to export yet."
            showAlert = true
            return
        }

        completedLiftsDocument = CompletedLiftsCSVDocument(history: workoutManager.history)
        showCSVExporter = true
    }
    
    func importBackup(from url: URL) {
        isImporting = true
        
        // FIXED: Replaced DispatchQueue with Task/MainActor for Swift 6 safety
        Task {
            let accessing = url.startAccessingSecurityScopedResource()
            defer {
                if accessing {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            
            var fileData: Data?
            var fileError: Error?
            
            let coordinator = NSFileCoordinator()
            coordinator.coordinate(readingItemAt: url, options: .withoutChanges, error: nil) { safeURL in
                do {
                    fileData = try Data(contentsOf: safeURL)
                } catch {
                    fileError = error
                }
            }
            
            // Perform UI updates on the Main Actor
            await MainActor.run {
                if let error = fileError {
                    self.alertMessage = "Failed to read file: \(error.localizedDescription)"
                    self.showAlert = true
                    self.isImporting = false
                    return
                }
                
                guard let data = fileData else {
                    self.isImporting = false
                    return
                }
                
                do {
                    // This is now safe because BackupData is Sendable
                    let backup = try JSONDecoder().decode(BackupData.self, from: data)
                    saveBackupData(backup)
                } catch {
                    self.alertMessage = "Import failed: \(error.localizedDescription)"
                    self.showAlert = true
                    self.isImporting = false
                }
            }
        }
    }
    
    func saveBackupData(_ backup: BackupData) {
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
        if let encodedBarbell = try? JSONEncoder().encode(backup.overriddenBarbellWeights) {
            UserDefaults.standard.set(encodedBarbell, forKey: "overridden_barbell_weights")
        }
        if let encodedProgression = try? JSONEncoder().encode(backup.overriddenProgressionAmounts) {
            UserDefaults.standard.set(encodedProgression, forKey: "overridden_progression_amounts_schedule")
        }
        if let encodedRestTimers = try? JSONEncoder().encode(backup.overriddenRestTimerDurations) {
            UserDefaults.standard.set(encodedRestTimers, forKey: "overridden_rest_timers_schedule")
        }
        
        if let encodedWeights = try? JSONEncoder().encode(backup.savedWeights) {
            UserDefaults.standard.set(encodedWeights, forKey: "exercise_database_weights")
        }
        UserDefaults.standard.set(backup.customExercises, forKey: "exercise_database_custom")
        UserDefaults.standard.set(backup.hiddenExercises, forKey: "exercise_database_hidden")
        
        self.squatMax = backup.squatMax
        self.benchMax = backup.benchMax
        self.deadliftMax = backup.deadliftMax
        self.hasOnboarded = backup.hasOnboarded
        
        workoutManager.reloadAllData()
        database.reload()
        
        isImporting = false
        alertMessage = "Import successful! All data has been restored."
        showAlert = true
    }
}

// MARK: - Native Document Picker Wrapper
struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void
    var onError: (Error) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.item], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            parent.onPick(url)
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            // No action needed
        }
    }
}
