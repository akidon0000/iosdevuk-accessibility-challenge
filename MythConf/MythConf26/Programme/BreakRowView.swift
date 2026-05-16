//
//  BreakRowView.swift
//  IOSDevuk26
//

import SwiftUI

/// A full-width row for non-session slots such as breaks, lunch, and social events.
struct BreakRowView: View {
    @Environment(ViewModel.self) private var viewModel
    let session: Session

    var body: some View {
        AStack(vAlignment: .leading) {
            TimeColumnView(
                startTime: session.startTimeText,
                endTime: session.endTimeText,
                actsAsHeader: false
            )

            VStack(alignment: .leading) {
                Text(session.sessionType.displayName)
                    .italic()
                    .foregroundStyle(.primary)
                if let talkID = session.contentIDs.first {
                    Text(viewModel.locationNameFrom(talkID: talkID))
                        .font(.caption)
                        .secondaryTextStyle()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(session.sessionType.color.opacity(0.12))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        // Break rows are not tappable. VoiceOver still reads them, but exclude
        // them from Voice Control / Switch Control / Full Keyboard targets.
        .accessibilityRespondsToUserInteraction(false)
    }

    private var accessibilityDescription: String {
        let timeRange = "Break Time from \(session.startTimeText.spokenTime) to \(session.endTimeText.spokenTime)"
        let typeName = session.sessionType.displayName
        if let talkID = session.contentIDs.first {
            return "\(timeRange), \(typeName) at \(viewModel.locationNameFrom(talkID: talkID))"
        }
        return "\(timeRange), \(typeName)"
    }
}
