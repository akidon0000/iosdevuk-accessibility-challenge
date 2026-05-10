//
//  ParallelTalkCardView.swift
//  IOSDevuk26
//

import SwiftUI

/// A card showing a single talk within a parallel-session slot.
struct ParallelTalkCardView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkID: UUID
    let session: Session
    var positionIndex: Int = 0
    var positionTotal: Int = 1

    private var combinedAccessibilityLabel: String {
        let base = "\(viewModel.talkTitleFrom(talkID: talkID)), by \(viewModel.speakersFrom(talkID: talkID)), at \(viewModel.locationNameFrom(talkID: talkID))"
        guard positionTotal > 1 else { return base }
        return "\(base), \(positionIndex + 1) of \(positionTotal)"
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            NavigationLink(value: TalkReference(talkID: talkID, session: session)) {
                VStack(alignment: .leading, spacing: 0) {
                    session.sessionType.color
                        .frame(height: 4)
                        .accessibilityHidden(true)

                    VStack(alignment: .leading) {
                        Text(viewModel.talkTitleFrom(talkID: talkID))
                            .bold()
                            .font(.subheadline)
                            .multilineTextAlignment(.leading)
                        Text(viewModel.speakersFrom(talkID: talkID))
                            .font(.caption)
                            .secondaryTextStyle()
                            .multilineTextAlignment(.leading)
                        Text(viewModel.locationNameFrom(talkID: talkID))
                            .font(.caption)
                            .secondaryTextStyle()
                        Spacer(minLength: 32) // reserve room for the overlaid favourite button
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(session.sessionType.color.opacity(0.1), in: .rect(cornerRadius: 10))
                .clipShape(.rect(cornerRadius: 10))
            }
            .accessibilityLabel(combinedAccessibilityLabel)
            .accessibilitySortPriority(1) // focus the card before the favourite button
            .buttonStyle(.plain)

            // FavouriteButton lives outside the NavigationLink so VoiceOver can focus it directly
            FavouriteButtonView(talk: viewModel.talkFrom(talkID: talkID))
                .padding()
                .accessibilitySortPriority(0)
        }
        .accessibilityElement(children: .contain) // keep card and its favourite button traversed together
    }
}
