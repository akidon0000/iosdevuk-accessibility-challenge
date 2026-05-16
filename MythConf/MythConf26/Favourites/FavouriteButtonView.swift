//
//  FavouriteButtonView.swift
//  IOSDevuk26
//

import SwiftUI

/// A button that toggles a talk as a favourite.
struct FavouriteButtonView: View {
    @Environment(ViewModel.self) private var viewModel
    let talk: Talk

    private var isFavourite: Bool { viewModel.isFavourite(talk: talk) }

    var body: some View {
        Button {
            if isFavourite {
                viewModel.removeFavourite(talk: talk)
            } else {
                viewModel.addFavourite(talk: talk)
            }
        } label: {
            Image(systemName: isFavourite ? "star.fill" : "star")
                .foregroundStyle(isFavourite ? Color.yellow : Color.textSecondary)
        }
        .accessibilityLabel(isFavourite ? "Remove session from favourites" : "Favourite")
        .sensoryFeedback(.success, trigger: isFavourite)
    }
}
