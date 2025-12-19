//
//  ExercisesView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI

struct ExercisesView: View {
    @EnvironmentObject var database: ExerciseDatabase
    @State private var searchText = ""
    @State private var showAddAlert = false
    @State private var newExerciseName = ""
    @State private var newExerciseWeight = ""
    
    var filteredExercises: [String] {
        if searchText.isEmpty {
            return database.allExerciseNames
        } else {
            return database.allExerciseNames.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search exercises...", text: $searchText)
                        .foregroundColor(.white)
                        .accentColor(.green)
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding()
                
                // List
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredExercises, id: \.self) { name in
                            ExerciseDatabaseRow(name: name)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .navigationTitle("Exercises")
        .background(Color.black)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    newExerciseName = ""
                    newExerciseWeight = ""
                    showAddAlert = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.green)
                }
            }
        }
        .alert("New Exercise", isPresented: $showAddAlert) {
            TextField("Exercise Name", text: $newExerciseName)
            TextField("Weight (Optional)", text: $newExerciseWeight)
                .keyboardType(.decimalPad)
            Button("Cancel", role: .cancel) { }
            Button("Add") {
                if !newExerciseName.isEmpty {
                    database.addCustomExercise(name: newExerciseName)
                    if let weight = Double(newExerciseWeight) {
                        database.saveWeight(for: newExerciseName, weight: weight)
                    }
                }
            }
        } message: {
            Text("Create a new exercise to track.")
        }
    }
}

struct ExerciseDatabaseRow: View {
    let name: String
    @EnvironmentObject var database: ExerciseDatabase
    @State private var weightInput: String = ""
    @FocusState private var isFocused: Bool
    
    @ScaledMetric var inputWidth: CGFloat = 60
    
    var savedWeight: Double? {
        database.getWeight(for: name)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(savedWeight != nil ? "Set: \(Int(savedWeight!)) lbs" : "Not set")
                        .font(.caption)
                        .foregroundColor(savedWeight != nil ? .green : .gray)
                }
                
                Spacer()
                
                // Input Field
                HStack(spacing: 5) {
                    TextField("0", text: $weightInput)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.white)
                        .frame(width: inputWidth)
                        .focused($isFocused)
                        .onChange(of: isFocused) {
                            if !isFocused {
                                save()
                            }
                        }
                        .onSubmit {
                            save()
                        }
                    
                    Text("lbs")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
                .background(Color.gray.opacity(0.3))
        }
        .onAppear {
            if let weight = savedWeight {
                weightInput = "\(Int(weight))"
            }
        }
    }
    
    func save() {
        if let value = Double(weightInput) {
            database.saveWeight(for: name, weight: value)
        }
    }
}

