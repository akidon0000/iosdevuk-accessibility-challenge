//
//  LocationDetailView.swift
//  IOSDevuk26
//

import SwiftUI
import MapKit

struct LocationDetailView: View {
    @Environment(ViewModel.self) private var viewModel
    let locationID: String

    private var location: Location { viewModel.locationFrom(locationID: locationID) }

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
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
                    .accessibilityLabel("Map showing \(location.name)")
                    .accessibilityHint("Opens Apple Maps to explore this location")
                }

                Text(location.placeDescription)
                    .secondaryTextStyle()
                    .padding()
            }
        }
        .navigationTitle(location.name)
        .navigationBarTitleDisplayMode(.large)
    }

    private func openInMaps() {
        let mapLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let mapItem = MKMapItem(location: mapLocation, address: nil)
        mapItem.name = location.name
        mapItem.openInMaps()
    }
}
