//
//  NavigationDemoApp.swift
//  NavigationDemo
//
//  Created by Stephen Beitzel on 6/21/22.
//

import SwiftUI

@main
struct NavigationDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            SidebarCommands()
        }
    }
}
