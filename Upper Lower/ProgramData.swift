//
//  ProgramData.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import Foundation

class ProgramData {
    static let shared = ProgramData()
    
    // Returns the correct workout data for any given week number.
    // Cycles back to Week 1 after Week 9.
    func getDays(forWeek week: Int) -> [WorkoutDay] {
        let cycleWeek = ((week - 1) % 9) + 1
        
        switch cycleWeek {
        case 1: return week1(weekNum: week)
        case 2: return week2(weekNum: week)
        case 3: return week3(weekNum: week)
        case 4: return week4(weekNum: week)
        case 5: return week5(weekNum: week)
        case 6: return week6(weekNum: week)
        case 7: return week7(weekNum: week)
        case 8: return week8(weekNum: week)
        case 9: return week9(weekNum: week)
        default: return week1(weekNum: week)
        }
    }
    
    // MARK: - Week 1 Data
    private func week1(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "4", liftType: .squat, percentageOf1RM: 0.75, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Stiff-Leg Deadlift", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "4-second lowering phase. Keep your hips high", equipment: .barbell),
                Exercise(name: "Dumbbell Walking Lunge", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 steps per leg", equipment: .dumbbell),
                Exercise(name: "Seated Leg Curl", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your hamstrings", equipment: .machine),
                Exercise(name: "Cable Pull-Through", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .cable),
                Exercise(name: "Standing Calf Raise", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "First 6 reps 3-second lowering phase, last 6 reps don't stop between reps", equipment: .machine),
                Exercise(name: "Cable Crunch", sets: 4, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Round your back as you crunch", equipment: .cable)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "6", liftType: .bench, percentageOf1RM: 0.7, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your elbows down and in", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Seated T-Bar Row", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze shoulder blades together at the top, control the weight", equipment: .machine),
                Exercise(name: "Dumbbell Incline Press", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "3-second pause", equipment: .dumbbell),
                Exercise(name: "Skull Crusher", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "8 reps, rest 5 seconds, 2 reps, rest 5 seconds, 2 reps", equipment: .barbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 2, reps: "5", liftType: .deadlift, percentageOf1RM: 0.8, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED: Renamed to Accessory, type .accessory, nil percentage
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Barbell Hip Thrust", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes at the top", equipment: .barbell),
                Exercise(name: "Leg Extension", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "12 reps each leg, bilateral concentric, unilateral eccentric", equipment: .machine),
                Exercise(name: "Lying Leg Curl", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .machine),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 3, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Barbell Bent Over Row", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "10 reps pendlay row, 10 reps bent over row", equipment: .barbell),
                Exercise(name: "Cable Fly 21s", sets: 3, reps: "21", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "7 reps top half of ROM, 7 reps bottom half ROM, 7 reps full ROM", equipment: .cable),
                Exercise(name: "Face Pulls", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your shoulder blades together", equipment: .cable),
                Exercise(name: "Machine Lateral Raise", sets: 3, reps: "24", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Dropset", equipment: .machine),
                Exercise(name: "Dumbbell Curl", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Supinate against the dumbbell", equipment: .dumbbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }

    // MARK: - Week 2 Data
    private func week2(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "5", liftType: .squat, percentageOf1RM: 0.75, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Stiff-Leg Deadlift", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "4-second lowering phase. Keep your hips high", equipment: .barbell),
                Exercise(name: "Dumbbell Walking Lunge", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 steps per leg", equipment: .dumbbell),
                Exercise(name: "Seated Leg Curl", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your hamstrings", equipment: .machine),
                Exercise(name: "Cable Pull-Through", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .cable),
                Exercise(name: "Standing Calf Raise", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "First 6 reps 3-second lowering phase, last 6 reps don't stop between reps", equipment: .machine),
                Exercise(name: "Cable Crunch", sets: 4, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Round your back as you crunch", equipment: .cable)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "7", liftType: .bench, percentageOf1RM: 0.7, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your elbows down and in", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 4, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Seated T-Bar Row", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze shoulder blades together at the top, control the weight", equipment: .machine),
                Exercise(name: "Dumbbell Incline Press", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "3-second pause", equipment: .dumbbell),
                Exercise(name: "Skull Crusher", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "8 reps, rest 5 seconds, 2 reps, rest 5 seconds, 2 reps", equipment: .barbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 3, reps: "5", liftType: .deadlift, percentageOf1RM: 0.8, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Barbell Hip Thrust", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes at the top", equipment: .barbell),
                Exercise(name: "Leg Extension", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "12 reps each leg, bilateral concentric, unilateral eccentric", equipment: .machine),
                Exercise(name: "Lying Leg Curl", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .machine),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 4, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Barbell Bent Over Row", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "10 reps pendlay row, 10 reps bent over row", equipment: .barbell),
                Exercise(name: "Cable Fly 21s", sets: 3, reps: "21", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "7 reps top half of ROM, 7 reps bottom half ROM, 7 reps full ROM", equipment: .cable),
                Exercise(name: "Face Pulls", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your shoulder blades together", equipment: .cable),
                Exercise(name: "Machine Lateral Raise", sets: 3, reps: "24", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Dropset", equipment: .machine),
                Exercise(name: "Dumbbell Curl", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Supinate against the dumbbell", equipment: .dumbbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }

    // MARK: - Week 3 Data
    private func week3(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "6", liftType: .squat, percentageOf1RM: 0.75, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Stiff-Leg Deadlift", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "4-second lowering phase. Keep your hips high", equipment: .barbell),
                Exercise(name: "Dumbbell Walking Lunge", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 steps per leg", equipment: .dumbbell),
                Exercise(name: "Seated Leg Curl", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your hamstrings", equipment: .machine),
                Exercise(name: "Cable Pull-Through", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .cable),
                Exercise(name: "Standing Calf Raise", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "First 6 reps 3-second lowering phase, last 6 reps don't stop between reps", equipment: .machine),
                Exercise(name: "Cable Crunch", sets: 4, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Round your back as you crunch", equipment: .cable)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: 0.7, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your elbows down and in", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 4, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Seated T-Bar Row", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze shoulder blades together at the top, control the weight", equipment: .machine),
                Exercise(name: "Dumbbell Incline Press", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "3-second pause", equipment: .dumbbell),
                Exercise(name: "Skull Crusher", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "8 reps, rest 5 seconds, 2 reps, rest 5 seconds, 2 reps", equipment: .barbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 4, reps: "5", liftType: .deadlift, percentageOf1RM: 0.8, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Barbell Hip Thrust", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes at the top", equipment: .barbell),
                Exercise(name: "Leg Extension", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "12 reps each leg, bilateral concentric, unilateral eccentric", equipment: .machine),
                Exercise(name: "Lying Leg Curl", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .machine),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 5, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Barbell Bent Over Row", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "10 reps pendlay row, 10 reps bent over row", equipment: .barbell),
                Exercise(name: "Cable Fly 21s", sets: 3, reps: "21", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "7 reps top half of ROM, 7 reps bottom half ROM, 7 reps full ROM", equipment: .cable),
                Exercise(name: "Face Pulls", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your shoulder blades together", equipment: .cable),
                Exercise(name: "Machine Lateral Raise", sets: 4, reps: "24", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Dropset", equipment: .machine),
                Exercise(name: "Dumbbell Curl", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Supinate against the dumbbell", equipment: .dumbbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }

    // MARK: - Week 4 Data (Start of Phase 2)
    private func week4(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "4", liftType: .squat, percentageOf1RM: 0.775, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Deficit Deadlift", sets: 2, reps: "6", liftType: .deadlift, percentageOf1RM: 0.7, rpeOrNotes: "2 inch deficit, can use 35 lb pates to create deficit", equipment: .barbell),
                Exercise(name: "Leg Press", sets: 4, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Low foot positioning", equipment: .machine),
                Exercise(name: "Seated Leg Curl", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your hamstrings", equipment: .machine),
                Exercise(name: "Cable Pull-Through", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .cable),
                Exercise(name: "Seated Calf Raise", sets: 2, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Press onto your toes", equipment: .machine),
                Exercise(name: "Hanging Leg Raise", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your spine", equipment: .bodyweight)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "6", liftType: .bench, percentageOf1RM: 0.725, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your elbows down and in", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Cable Row", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "2-second lowering phase", equipment: .cable),
                Exercise(name: "Machine Chest Press", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your chest", equipment: .machine),
                Exercise(name: "Cable Triceps Kickback", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your triceps", equipment: .cable),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 2, reps: "5", liftType: .deadlift, percentageOf1RM: 0.825, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Bulgarian Split Squat", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Elevate your back foot 12 inch", equipment: .dumbbell),
                Exercise(name: "Leg Extension", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your quads", equipment: .machine),
                Exercise(name: "Leg Curl", sets: 2, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .machine),
                Exercise(name: "Machine Hip Abduction", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes", equipment: .machine),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 3, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull with your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Dumbbell Row", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Brace onto a bench for support, pull your elbow against your side", equipment: .dumbbell),
                Exercise(name: "Pec Deck", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your pecs", equipment: .machine),
                Exercise(name: "Dumbbell Reverse Fly", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your shoulder blades together", equipment: .dumbbell),
                Exercise(name: "Dumbbell Front Raise/Lateral Raise", sets: 3, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 reps front raise, 15 reps lateral raise", equipment: .dumbbell),
                Exercise(name: "EZ Bar Curl 21s", sets: 3, reps: "21", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "7 reps bottom half of ROM, 7 reps top half of ROM, 7 reps full ROM", equipment: .barbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }

    // MARK: - Week 5 Data
    private func week5(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "5", liftType: .squat, percentageOf1RM: 0.775, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Deficit Deadlift", sets: 2, reps: "6", liftType: .deadlift, percentageOf1RM: 0.7, rpeOrNotes: "2 inch deficit, can use 35 lb pates to create deficit", equipment: .barbell),
                Exercise(name: "Leg Press", sets: 4, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Low foot positioning", equipment: .machine),
                Exercise(name: "Seated Leg Curl", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your hamstrings", equipment: .machine),
                Exercise(name: "Cable Pull-Through", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .cable),
                Exercise(name: "Seated Calf Raise", sets: 2, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Press onto your toes", equipment: .machine),
                Exercise(name: "Hanging Leg Raise", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your spine", equipment: .bodyweight)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "6", liftType: .bench, percentageOf1RM: 0.725, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your elbows down and in", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 4, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Cable Row", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "2-second lowering phase", equipment: .cable),
                Exercise(name: "Machine Chest Press", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your chest", equipment: .machine),
                Exercise(name: "Cable Triceps Kickback", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your triceps", equipment: .cable),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 3, reps: "5", liftType: .deadlift, percentageOf1RM: 0.825, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Bulgarian Split Squat", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Elevate your back foot 12 inch", equipment: .dumbbell),
                Exercise(name: "Leg Extension", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your quads", equipment: .machine),
                Exercise(name: "Leg Curl", sets: 2, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .machine),
                Exercise(name: "Machine Hip Abduction", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes", equipment: .machine),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 4, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull with your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Dumbbell Row", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Brace onto a bench for support, pull your elbow against your side", equipment: .dumbbell),
                Exercise(name: "Pec Deck", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your pecs", equipment: .machine),
                Exercise(name: "Dumbbell Reverse Fly", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your shoulder blades together", equipment: .dumbbell),
                Exercise(name: "Dumbbell Front Raise/Lateral Raise", sets: 3, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 reps front raise, 15 reps lateral raise", equipment: .dumbbell),
                Exercise(name: "EZ Bar Curl 21s", sets: 3, reps: "21", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "7 reps bottom half of ROM, 7 reps top half of ROM, 7 reps full ROM", equipment: .barbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }

    // MARK: - Week 6 Data
    private func week6(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "6", liftType: .squat, percentageOf1RM: 0.775, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Deficit Deadlift", sets: 2, reps: "6", liftType: .deadlift, percentageOf1RM: 0.7, rpeOrNotes: "2 inch deficit, can use 35 lb pates to create deficit", equipment: .barbell),
                Exercise(name: "Leg Press", sets: 4, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Low foot positioning", equipment: .machine),
                Exercise(name: "Seated Leg Curl", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your hamstrings", equipment: .machine),
                Exercise(name: "Cable Pull-Through", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .cable),
                Exercise(name: "Seated Calf Raise", sets: 2, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Press onto your toes", equipment: .machine),
                Exercise(name: "Hanging Leg Raise", sets: 4, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your spine", equipment: .bodyweight)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "6", liftType: .bench, percentageOf1RM: 0.725, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull your elbows down and in", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 4, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Cable Row", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "2-second lowering phase", equipment: .cable),
                Exercise(name: "Machine Chest Press", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your chest", equipment: .machine),
                Exercise(name: "Cable Triceps Kickback", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your triceps", equipment: .cable),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 4, reps: "5", liftType: .deadlift, percentageOf1RM: 0.825, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Bulgarian Split Squat", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Elevate your back foot 12 inch", equipment: .dumbbell),
                Exercise(name: "Leg Extension", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your quads", equipment: .machine),
                Exercise(name: "Leg Curl", sets: 2, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .machine),
                Exercise(name: "Machine Hip Abduction", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes", equipment: .machine),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 5, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull with your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Dumbbell Row", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Brace onto a bench for support, pull your elbow against your side", equipment: .dumbbell),
                Exercise(name: "Pec Deck", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your pecs", equipment: .machine),
                Exercise(name: "Dumbbell Reverse Fly", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your shoulder blades together", equipment: .dumbbell),
                Exercise(name: "Dumbbell Front Raise/Lateral Raise", sets: 4, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 reps front raise, 15 reps lateral raise", equipment: .dumbbell),
                Exercise(name: "EZ Bar Curl 21s", sets: 3, reps: "21", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "7 reps bottom half of ROM, 7 reps top half of ROM, 7 reps full ROM", equipment: .barbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }

    // MARK: - Week 7 Data (Start of Phase 3)
    private func week7(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "4", liftType: .squat, percentageOf1RM: 0.8, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Barbell Hip Thrust", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes at the top", equipment: .barbell),
                Exercise(name: "Knee-Banded Leg Press", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Keep your knees out", equipment: .machine),
                Exercise(name: "Sliding Leg Curl", sets: 2, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .bodyweight),
                Exercise(name: "Dumbbell Walking Lunge", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 steps per leg", equipment: .dumbbell),
                Exercise(name: "Standing Calf Raise", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Press onto your toes", equipment: .machine),
                Exercise(name: "Plank", sets: 4, reps: ":30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your abs", equipment: .bodyweight)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "6", liftType: .bench, percentageOf1RM: 0.75, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Underhand grip, pull your elbows against your sides", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 3, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Machine High Row", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Stretch your lats at the top", equipment: .machine),
                Exercise(name: "Push-Up", sets: 3, reps: "AMRAP", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your pecs", equipment: .bodyweight),
                Exercise(name: "Rope Overhead Triceps Extension", sets: 4, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Use your non-working arm to assist with the concentric", equipment: .cable),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 2, reps: "5", liftType: .deadlift, percentageOf1RM: 0.85, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Dumbbell Step-Up", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Set the box to ~parallel", equipment: .dumbbell),
                Exercise(name: "Reverse Hyper", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .machine),
                Exercise(name: "Single-Leg Leg Extension", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "12 reps each leg", equipment: .machine),
                Exercise(name: "Cable Standing Hip Abduction", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes", equipment: .cable),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 3, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull with your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Barbell Bent Over Row", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull to your upper abs", equipment: .barbell),
                Exercise(name: "Barbell Floor Press", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your chest", equipment: .barbell),
                Exercise(name: "Band Pull-Apart", sets: 2, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your shoulder blades together", equipment: .other),
                Exercise(name: "Arnold Press", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Start with your elbows in front of you and palms facing in. Rotate the dumbbells so that your palms face forward as you press", equipment: .dumbbell),
                Exercise(name: "Hammer Curl", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "3-second lowering phase", equipment: .dumbbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }

    // MARK: - Week 8 Data
    private func week8(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "5", liftType: .squat, percentageOf1RM: 0.8, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Barbell Hip Thrust", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes at the top", equipment: .barbell),
                Exercise(name: "Knee-Banded Leg Press", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Keep your knees out", equipment: .machine),
                Exercise(name: "Sliding Leg Curl", sets: 2, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .bodyweight),
                Exercise(name: "Dumbbell Walking Lunge", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 steps per leg", equipment: .dumbbell),
                Exercise(name: "Standing Calf Raise", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Press onto your toes", equipment: .machine),
                Exercise(name: "Plank", sets: 4, reps: ":30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your abs", equipment: .bodyweight)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "7", liftType: .bench, percentageOf1RM: 0.75, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Underhand grip, pull your elbows against your sides", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 4, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Machine High Row", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Stretch your lats at the top", equipment: .machine),
                Exercise(name: "Push-Up", sets: 3, reps: "AMRAP", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your pecs", equipment: .bodyweight),
                Exercise(name: "Rope Overhead Triceps Extension", sets: 4, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Use your non-working arm to assist with the concentric", equipment: .cable),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 3, reps: "5", liftType: .deadlift, percentageOf1RM: 0.85, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Dumbbell Step-Up", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Set the box to ~parallel", equipment: .dumbbell),
                Exercise(name: "Reverse Hyper", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .machine),
                Exercise(name: "Single-Leg Leg Extension", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "12 reps each leg", equipment: .machine),
                Exercise(name: "Cable Standing Hip Abduction", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes", equipment: .cable),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 4, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull with your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Barbell Bent Over Row", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull to your upper abs", equipment: .barbell),
                Exercise(name: "Barbell Floor Press", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your chest", equipment: .barbell),
                Exercise(name: "Band Pull-Apart", sets: 2, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your shoulder blades together", equipment: .other),
                Exercise(name: "Arnold Press", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Start with your elbows in front of you and palms facing in. Rotate the dumbbells so that your palms face forward as you press", equipment: .dumbbell),
                Exercise(name: "Hammer Curl", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "3-second lowering phase", equipment: .dumbbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }

    // MARK: - Week 9 Data
    private func week9(weekNum: Int) -> [WorkoutDay] {
        return [
            WorkoutDay(name: "Day 1", week: weekNum, exercises: [
                Exercise(name: "Back Squat", sets: 4, reps: "6", liftType: .squat, percentageOf1RM: 0.8, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Barbell Hip Thrust", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes at the top", equipment: .barbell),
                Exercise(name: "Knee-Banded Leg Press", sets: 3, reps: "20", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Keep your knees out", equipment: .machine),
                Exercise(name: "Sliding Leg Curl", sets: 2, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your hamstrings", equipment: .bodyweight),
                Exercise(name: "Dumbbell Walking Lunge", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "15 steps per leg", equipment: .dumbbell),
                Exercise(name: "Standing Calf Raise", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Press onto your toes", equipment: .machine),
                Exercise(name: "Plank", sets: 4, reps: ":30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Flex your spine", equipment: .bodyweight)
            ]),
            WorkoutDay(name: "Day 2", week: weekNum, exercises: [
                Exercise(name: "Barbell Bench Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: 0.75, rpeOrNotes: "Elbows at a 45° angle. Squeeze your shoulder blades and stay firm on the bench", equipment: .barbell),
                Exercise(name: "Lat Pulldown", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Underhand grip, pull your elbows against your sides", equipment: .machine),
                Exercise(name: "Barbell Overhead Press", sets: 4, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes to keep your torso upright", equipment: .barbell),
                Exercise(name: "Machine High Row", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Stretch your lats at the top", equipment: .machine),
                Exercise(name: "Push-Up", sets: 3, reps: "AMRAP", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your pecs", equipment: .bodyweight),
                Exercise(name: "Rope Overhead Triceps Extension", sets: 4, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Use your non-working arm to assist with the concentric", equipment: .cable),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 3", week: weekNum, exercises: [
                Exercise(name: "Deadlift", sets: 4, reps: "5", liftType: .deadlift, percentageOf1RM: 0.85, rpeOrNotes: "Brace your lats, chest tall, hips high, pull the slack out of the bar prior to moving it off the ground", equipment: .barbell),
                // CHANGED
                Exercise(name: "A1 Back Squat", sets: 3, reps: "8", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Sit back and down, 15° toe flare, drive your knees out laterally", equipment: .barbell),
                Exercise(name: "Dumbbell Step-Up", sets: 3, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Set the box to ~parallel", equipment: .dumbbell),
                Exercise(name: "Reverse Hyper", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your glutes", equipment: .machine),
                Exercise(name: "Single-Leg Leg Extension", sets: 2, reps: "12", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "12 reps each leg", equipment: .machine),
                Exercise(name: "Cable Standing Hip Abduction", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your glutes", equipment: .cable),
                Exercise(name: "Lower Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ]),
            WorkoutDay(name: "Day 4", week: weekNum, exercises: [
                Exercise(name: "Wide-Grip Pull-Up", sets: 5, reps: "6", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull with your chest to the bar", equipment: .bodyweight),
                Exercise(name: "Barbell Incline Press", sets: 4, reps: "8", liftType: .bench, percentageOf1RM: nil, rpeOrNotes: "Keep your elbows out", equipment: .barbell),
                Exercise(name: "Barbell Bent Over Row", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Pull to your upper abs", equipment: .barbell),
                Exercise(name: "Barbell Floor Press", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on squeezing your chest", equipment: .barbell),
                Exercise(name: "Band Pull-Apart", sets: 2, reps: "30", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Squeeze your shoulder blades together", equipment: .other),
                Exercise(name: "Arnold Press", sets: 4, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Start with your elbows in front of you and palms facing in. Rotate the dumbbells so that your palms face forward as you press", equipment: .dumbbell),
                Exercise(name: "Hammer Curl", sets: 3, reps: "10", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "3-second lowering phase", equipment: .dumbbell),
                Exercise(name: "Upper Body Weak Point 1", sets: 3, reps: "15", liftType: .accessory, percentageOf1RM: nil, rpeOrNotes: "Focus on mind-muscle connection", equipment: .other)
            ])
        ]
    }
}
