//
//  ProgrammeCountdownBanner.swift
//  IOSDevuk26
//

import Combine
import SwiftUI

/// Propagates the measured height of the Programme countdown banner so the
/// ScrollView underneath can add matching bottom inset and still let the user
/// scroll the last item into view above the banner.
struct ProgrammeBannerHeightKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// Pinned bottom banner that adapts to where we are relative to the
/// conference timeline (before / during a session / between sessions / after).
/// During a parallel slot it cycles through the running talks every few
/// seconds — unless Reduce Motion is on, in which case it shows a static
/// "N parallel talks" summary. Tap jumps to the current talk; long-press
/// opens the debug date override.
struct ProgrammeCountdownBanner: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let dateOverride: DateOverride
    let onTapCurrent: (TalkReference?) -> Void
    let onOpenDebug: () -> Void

    @State private var cycleIndex: Int = 0

    @State private var cycleTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    private var now: Date { dateOverride.now }

    private var confTimeType: ConfTimeType {
        viewModel.confData.whereInConf(now: now)
    }

    private var currentSession: Session? {
        viewModel.confData.currentSession(now: now)
    }

    private var currentTalks: [Talk] {
        guard let session = currentSession, session.containsTalk else { return [] }
        return session.contentIDs.map { viewModel.talkFrom(talkID: $0) }
    }

    private var displayedTalk: Talk? {
        let talks = currentTalks
        guard !talks.isEmpty else { return nil }
        return talks[cycleIndex % talks.count]
    }

    private var currentTalkReference: TalkReference? {
        guard let session = currentSession, let talk = displayedTalk else { return nil }
        return TalkReference(talkID: talk.id, session: session)
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.title3)
                .foregroundStyle(iconColor)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text("MythConf 2026")
                    .font(.headline)
                Text(secondaryText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .id(secondaryText)
                    .transition(.opacity)
            }
            Spacer(minLength: 0)
            if dateOverride.isOverriding {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.footnote)
                    .foregroundStyle(.orange)
                    .accessibilityLabel(Text("Date override active"))
            }
            if currentTalkReference != nil {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
        }
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 2)
        .contentShape(.rect(cornerRadius: 14))
        .onTapGesture {
            onTapCurrent(currentTalkReference)
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            onOpenDebug()
        }
        .onReceive(cycleTimer) { _ in
            advanceCycleIfNeeded()
        }
        .onChange(of: currentSession?.id) { _, _ in
            cycleIndex = 0
        }
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(combinedAccessibilityLabel)
        .accessibilityHint(accessibilityHintText)
        .accessibilityAddTraits(.isButton)
        .accessibilityInputLabels(accessibilityInputLabels)
        .accessibilityAction(named: Text("Open date override")) {
            onOpenDebug()
        }
    }

    // MARK: - Cycle

    private func advanceCycleIfNeeded() {
        let count = currentTalks.count
        guard !reduceMotion, count > 1 else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            cycleIndex = (cycleIndex + 1) % count
        }
    }

    // MARK: - State-driven content

    private var iconName: String {
        if currentTalks.count > 1 { return "person.2.fill" }
        if let session = currentSession {
            if let typed = session.sessionType.iconName { return typed }
            switch session.sessionType {
            case .teaBreak, .lunch:                              return "cup.and.saucer.fill"
            case .dinner, .confdinner:                           return "fork.knife"
            case .social:                                        return "bubbles.and.sparkles.fill"
            case .registration:                                  return "person.badge.key.fill"
            case .railtrip:                                      return "tram.fill"
            default:                                             break
            }
        }
        switch confTimeType {
        case .beforeConf:                                             return "calendar"
        case .beforeConfDayStart, .duringConfDay, .afterConfDayEnd:   return "sparkles"
        case .afterConf:                                              return "heart.fill"
        case .dummy:                                                  return "calendar"
        }
    }

    private var iconColor: Color {
        if let session = currentSession {
            switch session.sessionType {
            case .dummy: break
            default: return session.sessionType.color
            }
        }
        switch confTimeType {
        case .beforeConf:                                             return .accentColor
        case .beforeConfDayStart, .duringConfDay, .afterConfDayEnd:   return .orange
        case .afterConf:                                              return .pink
        case .dummy:                                                  return .accentColor
        }
    }

    private var secondaryText: String {
        switch confTimeType {
        case .beforeConf:
            let days = daysUntilConfStart
            if days <= 0 {
                return String(localized: "Starting soon", comment: "Programme banner subtitle when the conference begins later today.")
            }
            return String(localized: "\(days) days to go", comment: "Programme banner subtitle showing how many days remain until the conference starts.")
        case .afterConf:
            return String(localized: "Thanks for joining — see you in 2027", comment: "Programme banner subtitle after the conference has ended.")
        case .beforeConfDayStart, .duringConfDay, .afterConfDayEnd:
            if let session = currentSession {
                if session.containsTalk {
                    let talks = currentTalks
                    if talks.count > 1 {
                        if reduceMotion {
                            return String(localized: "Now · \(talks.count) parallel talks", comment: "Programme banner subtitle when multiple talks run in parallel and Reduce Motion is on.")
                        } else if let talk = displayedTalk {
                            return String(localized: "Now: \(talk.talkTitle)", comment: "Programme banner subtitle showing the title of the talk currently being cycled through.")
                        }
                    } else if let talk = talks.first {
                        return String(localized: "Now: \(talk.talkTitle)", comment: "Programme banner subtitle showing the title of the talk currently happening.")
                    }
                } else {
                    return String(localized: "Now: \(session.sessionType.displayName)", comment: "Programme banner subtitle showing the name of the current non-talk session (e.g. lunch, registration).")
                }
            }
            if let dayNumber = currentConfDayNumber {
                return String(localized: "Happening now · Day \(dayNumber)", comment: "Programme banner subtitle on a conference day, showing which day of the conference it is.")
            }
            return String(localized: "Happening now", comment: "Programme banner subtitle on a conference day when the day number is unavailable.")
        case .dummy:
            return String(localized: "iOSDevUK", comment: "Programme banner fallback subtitle when conference dates aren't available.")
        }
    }

    // MARK: - Accessibility

    /// For VoiceOver during a parallel slot we read *all* talk titles, not
    /// just the one currently being cycled — so the user gets the complete
    /// picture in a single utterance instead of having to wait through the
    /// cycle.
    private var combinedAccessibilityLabel: String {
        switch confTimeType {
        case .beforeConfDayStart, .duringConfDay, .afterConfDayEnd:
            if let session = currentSession, session.containsTalk {
                let talks = currentTalks
                if talks.count > 1 {
                    let titles = talks.map(\.talkTitle).joined(separator: ", ")
                    return String(localized: "MythConf 2026, now: \(talks.count) parallel talks: \(titles)", comment: "VoiceOver label for the Programme banner during a parallel slot, listing every running talk title.")
                }
            }
            return "MythConf 2026, \(secondaryText)"
        default:
            return "MythConf 2026, \(secondaryText)"
        }
    }

    private var accessibilityHintText: Text {
        if currentTalkReference != nil {
            return Text("Opens the current session. Use Open date override for the debug controls.", comment: "VoiceOver hint when the banner is tappable into a session detail.")
        }
        return Text("Use Open date override for the debug controls.", comment: "VoiceOver hint when the banner only exposes the debug action.")
    }

    private var accessibilityInputLabels: [String] {
        var labels = ["MythConf countdown", "Countdown", "Date override"]
        if currentTalkReference != nil {
            labels.insert(contentsOf: ["Current session", "Open current talk", "Now playing"], at: 0)
        }
        return labels
    }

    // MARK: - Date math

    private var daysUntilConfStart: Int {
        guard let firstSession = viewModel.confData.sessions.first?.first else { return 0 }
        let cal = Calendar.current
        let startDay = cal.startOfDay(for: firstSession.startTime)
        let nowDay = cal.startOfDay(for: now)
        return cal.dateComponents([.day], from: nowDay, to: startDay).day ?? 0
    }

    private var currentConfDayNumber: Int? {
        let cal = Calendar.current
        for (idx, daySessions) in viewModel.confData.sessions.enumerated() {
            guard let first = daySessions.first else { continue }
            if cal.isDate(now, inSameDayAs: first.startTime) {
                return idx + 1
            }
        }
        return nil
    }
}
