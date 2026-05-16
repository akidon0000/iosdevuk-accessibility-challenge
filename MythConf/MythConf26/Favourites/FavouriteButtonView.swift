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
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isFavourite ? Color.yellow : Color.textSecondary)
                .overlay(alignment: .topTrailing) {
                    if isFavourite {
                        Image(systemName: "sparkles")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(Color.yellow)
                            .offset(x: 6, y: -3)
                    }
                }
                .frame(width: 44, height: 44)
                .contentShape(.rect)
        }
        .accessibilityLabel(isFavourite ? "Remove session from favourites" : "Favourite")
        .accessibilityInputLabels([
            "Favourite", "Favorite", "Star", "Bookmark",
            "Save", "Add to schedule", "Remove from schedule"
        ])
        .sensoryFeedback(.success, trigger: isFavourite)
    }
}
