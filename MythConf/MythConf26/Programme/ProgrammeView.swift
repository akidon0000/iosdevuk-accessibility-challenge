//
//  ProgrammeView.swift
//  IOSDevuk26
//

import SwiftUI

struct ProgrammeView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.locale) private var locale
    @State private var selectedDayIndex = 0
    @State private var isShowingDateOverrideSheet = false
    @State private var bannerHeight: CGFloat = 0
    @State private var navigationPath = NavigationPath()
    private let dateOverride = DateOverride.shared

    private var days: [[Session]] { viewModel.confData.sessions }

    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                            DayScheduleView(sessions: days[index], bottomInset: bannerHeight)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .overlay(alignment: .bottom) {
                ProgrammeCountdownBanner(
                    dateOverride: dateOverride,
                    onTapCurrent: { reference in
                        if let reference {
                            navigationPath.append(reference)
                        } else {
                            isShowingDateOverrideSheet = true
                        }
                    },
                    onOpenDebug: { isShowingDateOverrideSheet = true }
                )
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: ProgrammeBannerHeightKey.self, value: proxy.size.height)
                    }
                }
            }
            .onPreferenceChange(ProgrammeBannerHeightKey.self) { newValue in
                bannerHeight = newValue
            }
            .sheet(isPresented: $isShowingDateOverrideSheet) {
                DebugDateOverrideSheet(dateOverride: dateOverride)
            }
            .navigationTitle("MythConf 2026")
            .navigationBarTitleDisplayMode(.inline)
            .landscapeHidesNavigationBar(verticalSizeClass: verticalSizeClass)
            .onAppear {
                let confTimeType = viewModel.confData.whereInConf(now: dateOverride.now)
                guard confTimeType != .beforeConf, confTimeType != .afterConf else { return }
                if let todayIndex = days.firstIndex(where: { sessions in
                    guard let first = sessions.first else { return false }
                    return Calendar.current.isDate(dateOverride.now, inSameDayAs: first.startTime)
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
        let day = first.startTime.formatted(.dateTime.day().locale(locale))
        let weekday = first.startTime.formatted(.dateTime.weekday(.abbreviated).locale(locale))
        return "\(day) \(weekday)"
    }

    private func pickerAccessibilityLabel(for index: Int) -> String {
        String(localized: "Day \(index + 1), \(dayLabel(for: days[index]))")
    }

    private func pickerInputLabels(for index: Int) -> [String] {
        let dayN = String(localized: "Day \(index + 1)")
        guard let first = days[index].first else { return [dayN] }
        let weekdayFull = first.startTime.formatted(.dateTime.weekday(.wide).locale(locale))
        let weekdayShort = first.startTime.formatted(.dateTime.weekday(.abbreviated).locale(locale))
        let day = first.startTime.formatted(.dateTime.day().locale(locale))
        // Combined "3 Thursday" / "3 Thu" matches the visible tab label so
        // Voice Control users can say what they see. Keep "Day N" and the
        // bare weekday as alternates for shorter spoken commands.
        return [
            "\(day) \(weekdayFull)",
            "\(day) \(weekdayShort)",
            weekdayFull,
            weekdayShort,
            dayN,
        ]
    }
}

#Preview {
    ProgrammeView()
        .environment(ViewModel())
}
