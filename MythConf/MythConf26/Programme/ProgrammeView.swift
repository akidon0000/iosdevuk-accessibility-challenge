//
//  ProgrammeView.swift
//  IOSDevuk26
//

import SwiftUI

struct ProgrammeView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var selectedDayIndex = 0

    private var days: [[Session]] { viewModel.confData.sessions }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Conference day", selection: $selectedDayIndex) {
                    ForEach(days.indices, id: \.self) { index in
                        Text(dayLabel(for: days[index]))
                            .tag(index)
                            .accessibilityLabel(pickerAccessibilityLabel(for: index))
                            .accessibilityInputLabels(pickerInputLabels(for: index))
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if !days.isEmpty {
                    TabView(selection: $selectedDayIndex) {
                        ForEach(days.indices, id: \.self) { index in
                            DayScheduleView(sessions: days[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("MythConf 2026")
            .navigationBarTitleDisplayMode(.inline)
            .landscapeHidesNavigationBar(verticalSizeClass: verticalSizeClass)
            .onAppear {
                let confTimeType = viewModel.confData.whereInConf()
                guard confTimeType != .beforeConf, confTimeType != .afterConf else { return }
                if let todayIndex = days.firstIndex(where: { sessions in
                    guard let first = sessions.first else { return false }
                    return Calendar.current.isDateInToday(first.startTime)
                }) {
                    selectedDayIndex = todayIndex
                }
            }
            .conferenceNavigationDestinations()
            .languageToggleToolbar()
        }
    }

    private func dayLabel(for sessions: [Session]) -> String {
        guard let first = sessions.first else { return "" }
        return first.startTime.formatted(.dateTime.weekday(.abbreviated))
    }

    private func pickerAccessibilityLabel(for index: Int) -> String {
        String(localized: "Day \(index + 1), \(dayLabel(for: days[index]))")
    }

    private func pickerInputLabels(for index: Int) -> [String] {
        let dayN = String(localized: "Day \(index + 1)")
        guard let first = days[index].first else { return [dayN] }
        let weekdayFull = first.startTime.formatted(.dateTime.weekday(.wide))
        let weekdayShort = first.startTime.formatted(.dateTime.weekday(.abbreviated))
        return [weekdayFull, weekdayShort, dayN]
    }
}

#Preview {
    ProgrammeView()
        .environment(ViewModel())
}
