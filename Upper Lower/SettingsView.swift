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
    @State private var showFileImporter = false
    @State private var backupDocument: BackupDocument?
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isImporting = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                List {
                    Section(header: Text("Data Management").foregroundColor(.gray)) {
                        Button(action: prepareExport) {
                            Label("Export Backup", systemImage: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                        
                        Button(action: { showFileImporter = true }) {
                            HStack {
                                Label("Import Backup", systemImage: "square.and.arrow.down")
                                    .foregroundColor(.white)
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
                                    .foregroundColor(.white)
                                Text("Developed by Slowie")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .fontWeight(.medium)
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
            // IMPORT HANDLER
            .sheet(isPresented: $showFileImporter) {
                DocumentPicker(onPick: { url in
                    importBackup(from: url)
                }, onError: { error in
                    alertMessage = "Import failed: \(error.localizedDescription)"
                    showAlert = true
                })
            }
            .alert("Backup", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .preferredColorScheme(.dark)
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
            savedWeights: database.savedWeights,
            customExercises: database.customExercises,
            squatMax: squatMax,
            benchMax: benchMax,
            deadliftMax: deadliftMax,
            hasOnboarded: hasOnboarded
        )
        
        self.backupDocument = BackupDocument(data: backup)
        self.showFileExporter = true
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
        
        if let encodedWeights = try? JSONEncoder().encode(backup.savedWeights) {
            UserDefaults.standard.set(encodedWeights, forKey: "exercise_database_weights")
        }
        UserDefaults.standard.set(backup.customExercises, forKey: "exercise_database_custom")
        
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
