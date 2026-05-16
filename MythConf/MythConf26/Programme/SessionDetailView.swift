//
//  SessionDetailView.swift
//  IOSDevuk26
//

import SwiftUI

struct SessionDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let talkReference: TalkReference

    private var talk: Talk { viewModel.talkFrom(talkID: talkReference.talkID) }
    private var session: Session { talkReference.session }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                // Time and location
                AStack(vAlignment: .leading) {
                    Label(session.timeRange, systemImage: "clock")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("From \(session.startTimeText.spokenTime) to \(session.endTimeText.spokenTime)")
                    NavigationLink(value: LocationNavigationID(value: talk.locationID)) {
                        Label(viewModel.locationNameFrom(locationID: talk.locationID), systemImage: "mappin")
                    }
                }
                .font(.subheadline)
                .secondaryTextStyle()
                .padding(.bottom)

                // Speakers
                ForEach(talk.speakerIDs, id: \.self) { speakerID in
                    NavigationLink(value: SpeakerNavigationID(value: speakerID)) {
                        SpeakerRowView(speakerID: speakerID)
                    }
                    .buttonStyle(.plain)
                }

                Divider()
                    .padding(.vertical)

                // Abstract
                Text("About this talk")
                    .accessibilityAddTraits(.isHeader)
                    .frame(width: 0, height: 0)
                    .clipped()
                Text(talk.talkDescription)
            }
            .padding()
        }
        .navigationTitle(talk.talkTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FavouriteButtonView(talk: talk)
            }
        }
    }
}
