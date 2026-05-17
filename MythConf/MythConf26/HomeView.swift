//
//  HomeView.swift
//  IOSDevuk26
//
//  Created by Chris Price on 25/03/2026.
//

import SwiftUI

struct HomeView: View {
    /// Tracks the currently selected tab outside the TabView so the value
    /// survives the `.id(...)` rebuild we trigger on rotation.
    @State private var selectedTab: TabSection = .programme
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Programme", systemImage: "calendar", value: TabSection.programme) {
                ProgrammeView()
            }
            Tab("Speakers", systemImage: "person.2", value: TabSection.speakers) {
                SpeakersView()
            }
            Tab("Locations", systemImage: "map", value: TabSection.locations) {
                LocationsView()
            }
            Tab("My Schedule", systemImage: "star", value: TabSection.mySchedule) {
                MyScheduleView()
            }
        }
        // Rebuild the TabView when the vertical size class changes (i.e. on
        // rotation between portrait and landscape) so the tab bar recomputes
        // its item widths instead of keeping the stale portrait/landscape
        // layout. Selection survives because `selectedTab` lives outside.
        .id(verticalSizeClass)
    }

    private enum TabSection: Hashable {
        case programme
        case speakers
        case locations
        case mySchedule
    }
}

#Preview {
    HomeView()
}
