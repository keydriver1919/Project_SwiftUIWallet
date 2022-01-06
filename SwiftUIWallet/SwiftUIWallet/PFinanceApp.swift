//
//  PFinanceApp.swift
//  SwiftUIWallet
//
//  Created by change on 10/6/2021.
//

import SwiftUI

@main
struct PFinanceApp: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            DashboardView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
