//
//  SpeakersView.swift
//  IOSDevuk26
//

import SwiftUI

struct SpeakersView: View {
    @Environment(ViewModel.self) private var viewModel
    @State private var searchText = ""
    @State private var isSearchFocused = false

    private var filteredSpeakers: [Speaker] {
        let sorted = viewModel.confData.speakers.sorted()
        if searchText.isEmpty { return sorted }
        return sorted.filter { $0.name.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredSpeakers) { speaker in
                NavigationLink(value: SpeakerNavigationID(value: speaker.id)) {
                    SpeakerRowView(speakerID: speaker.id)
                }
            }
            .overlay {
                if filteredSpeakers.isEmpty, !searchText.isEmpty {
                    ContentUnavailableView(
                        "No search results",
                        systemImage: "magnifyingglass",
                        description: Text("No speakers match “\(searchText)”.")
                    )
                }
            }
            .searchable(text: $searchText, prompt: "Search speakers")
            .accessibilityInputLabels([
                "Search", "Find speaker", "Search speakers", "Filter"
            ])
            .navigationTitle("Speakers")
            .conferenceNavigationDestinations()
            .languageToggleToolbar()
            .background {
                Button("Focus search") { isSearchFocused = true }
                    .keyboardShortcut("f", modifiers: .command)
                    .hidden()
                    .accessibilityHidden(true)
            }
        }
    }
}

#Preview {
    SpeakersView()
        .environment(ViewModel())
}
