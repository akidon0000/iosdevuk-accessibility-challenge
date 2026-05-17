//
//  IOSDevuk26App.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

@main
struct MythConf: App {
    @State private var viewModel = ViewModel()
    @State private var networkMonitor = NetworkMonitor()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(viewModel)
                .environment(networkMonitor)
                .task {
                    // Pre-fetch venue map snapshots so the Locations screens
                    // remain usable when the network is unavailable. Only
                    // missing files are generated, so this is a no-op on
                    // subsequent launches.
                    await LocationMapSnapshotCache.shared.prefetchMissing(
                        locations: viewModel.confData.locations
                    )
                }
        }
    }
}
