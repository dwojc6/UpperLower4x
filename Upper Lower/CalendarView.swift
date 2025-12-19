//
//  CalendarView.swift
//  Upper Lower
//
//  Created by David Wojcik III on 12/7/25.
//

import SwiftUI

struct CalendarView: View {
    @Binding var selectedDate: Date
    let workoutDates: Set<DateComponents>
    
    @State private var currentMonth: Date = Date()
    @State private var slideEdge: Edge = .trailing // Controls the slide direction
    
    private let calendar = Calendar.current
    
    // Dynamic days of week header (S, M, T...)
    private var daysOfWeek: [String] {
        let formatter = DateFormatter()
        formatter.locale = .current
        return formatter.shortStandaloneWeekdaySymbols
    }
    
    // Calculate the exact dates to display in the grid
    private var days: [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return [] }
        let monthStart = monthInterval.start
        let monthEnd = monthInterval.end
        
        let startWeekday = calendar.component(.weekday, from: monthStart)
        // Calculate days to subtract to reach the start of the week row
        let daysToSubtract = (startWeekday - calendar.firstWeekday + 7) % 7
        let startOfGrid = calendar.date(byAdding: .day, value: -daysToSubtract, to: monthStart)!
        
        var result = [Date]()
        var current = startOfGrid
        
        // Generate dates until we pass the end of the month AND complete the week row
        while current < monthEnd || calendar.component(.weekday, from: current) != calendar.firstWeekday {
            result.append(current)
            if let next = calendar.date(byAdding: .day, value: 1, to: current) {
                current = next
            } else {
                break
            }
            // Safety limit (6 rows max)
            if result.count >= 42 { break }
        }
        return result
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Header (Month + Nav)
            HStack {
                Button(action: { changeMonth(by: -1) }) {
                    Image(systemName: "chevron.left")
                        .font(.body.bold())
                        .foregroundColor(.green)
                }
                Spacer()
                Text(currentMonth.formatted(.dateTime.month(.wide).year()))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Spacer()
                Button(action: { changeMonth(by: 1) }) {
                    Image(systemName: "chevron.right")
                        .font(.body.bold())
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 8)
            
            // MARK: - Days of Week
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day.prefix(1))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // MARK: - Days Grid with Slide Transition
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days, id: \.self) { date in
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isWorkoutDay = isWorkoutDay(date)
                    let isToday = calendar.isDateInToday(date)
                    let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                    
                    Button(action: {
                        withAnimation { selectedDate = date }
                    }) {
                        Text("\(calendar.component(.day, from: date))")
                            .font(.subheadline)
                            .fontWeight(isSelected || isWorkoutDay || isToday ? .bold : .regular)
                            .foregroundColor(textColor(isSelected: isSelected, isWorkoutDay: isWorkoutDay, isToday: isToday, isCurrentMonth: isCurrentMonth))
                            .frame(width: 32, height: 32)
                            .background(backgroundView(isSelected: isSelected, isWorkoutDay: isWorkoutDay))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            // ID triggers the transition when the month changes
            .id(currentMonth)
            .transition(.asymmetric(
                insertion: .move(edge: slideEdge),
                removal: .move(edge: slideEdge == .trailing ? .leading : .trailing)
            ))
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .onAppear {
            currentMonth = selectedDate
        }
        // Mask ensures the sliding content stays within the rounded corners
        .contentShape(Rectangle())
        .clipped()
    }
    
    // MARK: - Helpers
    
    func changeMonth(by value: Int) {
        // Determine slide direction
        slideEdge = value > 0 ? .trailing : .leading
        
        withAnimation(.easeInOut(duration: 0.3)) {
            if let newMonth = calendar.date(byAdding: .month, value: value, to: currentMonth) {
                currentMonth = newMonth
            }
        }
    }
    
    func isWorkoutDay(_ date: Date) -> Bool {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        return workoutDates.contains(comps)
    }
    
    func textColor(isSelected: Bool, isWorkoutDay: Bool, isToday: Bool, isCurrentMonth: Bool) -> Color {
        if isSelected { return .black }
        if isWorkoutDay { return .white } // Workout days now have White text (on Green circle)
        if isToday { return .green }      // "Today" keeps Green text if no workout
        return isCurrentMonth ? .white : .gray.opacity(0.4)
    }
    
    @ViewBuilder
    func backgroundView(isSelected: Bool, isWorkoutDay: Bool) -> some View {
        if isSelected {
            Circle().fill(Color.white)
        } else if isWorkoutDay {
            Circle().fill(Color.green) // Green Circle for workouts
        } else {
            Color.clear
        }
    }
}
