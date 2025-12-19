//
//  Upper_LowerApp.swift
//  Upper Lower
//
//  Created by David Wojcik III on 11/30/25.
//

import SwiftUI

@main
struct Upper_LowerApp: App {
    // 1. Create the manager here so we can access it for scenePhase logic
    @StateObject private var workoutManager = WorkoutManager()
    
    // 2. Watch for background/foreground states
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                // 3. Inject it into the view hierarchy
                // (Note: We remove @StateObject from ContentView and use @EnvironmentObject there instead)
                .environmentObject(workoutManager)
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .background:
                workoutManager.handleAppBackgrounding()
            case .active:
                workoutManager.handleAppForegrounding()
            case .inactive:
                break
            @unknown default:
                break
            }
        }
    }
}
