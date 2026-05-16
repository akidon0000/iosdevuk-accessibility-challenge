//
//  LocationDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let locationID: String

    @State private var isInlineTitleVisible = true

    private var location: Location { viewModel.locationFrom(locationID: locationID) }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(location.name)
                    .font(.title2)
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                    .padding(.horizontal)
                    .padding(.bottom, 4)
                    .onScrollVisibilityChange(threshold: 0.1) { visible in
                        isInlineTitleVisible = visible
                    }

                Map(initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        latitudinalMeters: 500,
                        longitudinalMeters: 500
                    )
                )) {
                    Marker(location.name, coordinate: coordinate)
                }
                .frame(height: 400)
                .clipShape(.rect(cornerRadius: 12))
                .padding(.horizontal)
                .accessibilityRepresentation {
                    // Substitute the map's complex a11y subtree with a single button that
                    // VoiceOver/Switch Control users can activate to open Apple Maps.
                    Button("") {
                        openInMaps()
                    }
                    .accessibilityLabel("Open in Maps: \(location.name)")
                }

                Text(location.placeDescription)
                    .secondaryTextStyle()
                    .padding()
            }
        }
        .toolbar {
            if !isInlineTitleVisible {
                ToolbarItem(placement: .principal) {
                    Text(location.name)
                        .font(.headline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
        }
    }

    private func openInMaps() {
        let mapLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let mapItem = MKMapItem(location: mapLocation, address: nil)
        mapItem.name = location.name
        mapItem.openInMaps()
    }
}
