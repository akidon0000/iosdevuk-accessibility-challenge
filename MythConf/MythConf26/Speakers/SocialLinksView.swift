//
//  SocialLinksView.swift
//  IOSDevuk26
//

import SwiftUI

/// A horizontal row of tappable social/web links for a speaker.
struct SocialLinksView: View {
    let social: [SocialItem]

    var body: some View {
        AStack(vAlignment: .leading) {
            ForEach(social, id: \.self) { item in
                if let url = URL(string: item.socialLink) {
                    Link(destination: url) {
                        Label(item.socialType.capitalized, systemImage: iconName(for: item.socialType))
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 4)
                    }
                    .contentShape(.rect)
                    .accessibilityInputLabels(inputLabels(for: item.socialType))
                }
            }
        }
    }

    private func iconName(for type: String) -> String {
        switch type.lowercased() {
        case "twitter", "x": return "at"
        case "mastodon": return "at.badge.plus"
        case "github": return "chevron.left.forwardslash.chevron.right"
        case "linkedin": return "person.crop.square"
        case "website", "web", "blog": return "globe"
        default: return "link"
        }
    }

    private func inputLabels(for type: String) -> [String] {
        switch type.lowercased() {
        case "twitter", "x": return ["Twitter", "X", "Tweet"]
        case "mastodon": return ["Mastodon", "Toot"]
        case "github": return ["GitHub", "Repository", "Code", "Source"]
        case "linkedin": return ["LinkedIn", "Profile"]
        case "website", "web", "blog":
            return ["Website", "Web", "Homepage", "Blog", "Site"]
        default: return [type.capitalized, "Link"]
        }
    }
}
