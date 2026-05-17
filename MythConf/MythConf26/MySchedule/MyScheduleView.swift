//
//  MyScheduleView.swift
//  IOSDevuk26
//

import SwiftUI

struct MyScheduleView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.favouriteIds.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text("No Favourites Yet")
                        } icon: {
                            Image(systemName: "star")
                                .secondaryTextStyle()
                        }
                    } description: {
                        Text("Tap the star on any session in the Programme to save it here.")
                            .secondaryTextStyle()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            ForEach(viewModel.favouritesBySession.indices, id: \.self) { dayIndex in
                                let daySessions = viewModel.favouritesBySession[dayIndex]
                                if daySessions.first?.sessionType != .dummy {
                                    Section {
                                        ForEach(daySessions) { session in
                                            ParallelSessionsRowView(session: session)
                                            Divider()
                                        }
                                    } header: {
                                        Text(dayHeader(for: daySessions))
                                            .font(.headline)
                                            .bold()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.horizontal)
                                            .padding(.vertical, 8)
                                            .background(.regularMaterial)
                                            .accessibilityAddTraits(.isHeader)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("My Schedule")
            .landscapeHidesNavigationBar(verticalSizeClass: verticalSizeClass)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .conferenceNavigationDestinations()
            .languageToggleToolbar()
        }
    }

    private func dayHeader(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }
}

#Preview {
    MyScheduleView()
        .environment(ViewModel())
}
