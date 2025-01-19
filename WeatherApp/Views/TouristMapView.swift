//
//  TouristMapView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-25.
//

import SwiftUI
import MapKit
import Foundation
import CoreLocation

/// A view that displays a map with tourist destinations for a given city.
/// Users can view and select destinations, and navigate to detailed views.
struct TouristDestination: Identifiable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let rating: Double
    let category: String
    let description: String
    let imageSystemName: String
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct TouristMapView: View {
    let city: LocationModel

    @State private var region: MKCoordinateRegion
    @State private var touristDestinations: [TouristDestination] = []
    @State private var isLoading = false
    @State private var selectedDestination: TouristDestination?
    @State private var showingDetail = false
    @State private var sheetHeight: CGFloat = UIScreen.main.bounds.height * 0.3

    init(city: LocationModel) {
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: city.lat, longitude: city.lon),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
        self.city = city
    }

    var body: some View {
        ZStack {
            // Map View
            Map(coordinateRegion: $region,
                interactionModes: .all,
                showsUserLocation: true,
                annotationItems: touristDestinations) { destination in
                MapAnnotation(coordinate: destination.coordinate) {
                    CustomMapPin(
                        destination: destination,
                        isSelected: selectedDestination?.id == destination.id,
                        action: {
                            withAnimation(.spring()) {
                                selectedDestination = destination
                                showingDetail = true
                            }
                        }
                    )
                }
            }
            .ignoresSafeArea()

            // Top Bar with City Name
            VStack {
                HStack {
                    Text(city.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Material.ultraThinMaterial)
                        )
                    Spacer()

                    Button(action: fetchTouristDestinations) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title3)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Material.ultraThinMaterial)
                            )
                    }
                }
                .padding()
                Spacer()
            }

            if isLoading {
                CustomLoadingView()
            }

            // Bottom Sheet with Attractions List
            BottomSheetView(
                maxHeight: UIScreen.main.bounds.height * 0.7,
                minHeight: UIScreen.main.bounds.height * 0.3,
                currentHeight: $sheetHeight
            ) {
                AttractionsList(
                    destinations: touristDestinations,
                    selectedDestination: $selectedDestination,
                    onDestinationSelect: { destination in
                        withAnimation {
                            centerMap(on: destination)
                            selectedDestination = destination
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let destination = selectedDestination {
                EnhancedDestinationDetailView(destination: destination)
            }
        }
        .onAppear {
            fetchTouristDestinations()
        }
    }

    // MARK: - Helper Methods

    private func fetchTouristDestinations() {
        // Start by setting the loading state to true
        isLoading = true

        // Create a request to search for tourist attractions
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "tourist attractions" // Search query for tourist attractions
        request.region = region // Search within the specified map region

        // Initialize a local search with the request
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            // Reset the loading state once the search completes
            isLoading = false

            // Check if the response is valid and there's no error
            guard let response = response, error == nil else {
                // If there's an error or no results, exit the function
                return
            }

            // Process the search results, limiting to the top 5 destinations
            let processedDestinations = response.mapItems.prefix(5).map { item -> TouristDestination in
                // Assign a category based on the item's name
                let category = assignCategory(for: item.name ?? "")

                // Return a TouristDestination object with relevant details
                return TouristDestination(
                    name: item.name ?? "Unknown Location", // Name of the destination
                    address: item.placemark.title ?? "Unknown address", // Address from the placemark
                    latitude: item.placemark.coordinate.latitude, // Latitude of the destination
                    longitude: item.placemark.coordinate.longitude, // Longitude of the destination
                    rating: Double.random(in: 4.0...5.0), // Assign a random rating between 4.0 and 5.0
                    category: category, // Assigned category
                    description: generateDescription(for: category), // Generate a description based on the category
                    imageSystemName: assignSystemImage(for: category) // Assign a relevant system image for the category
                )
            }

            // Update the touristDestinations array with the processed results
            withAnimation {
                touristDestinations = Array(processedDestinations)
            }
        }
    }

    private func centerMap(on destination: TouristDestination) {
        withAnimation(.easeInOut(duration: 0.5)) {
            region = MKCoordinateRegion(
                center: destination.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }

    private func assignCategory(for name: String) -> String {
        let name = name.lowercased()
        if name.contains("museum") { return "Museum" }
        if name.contains("park") { return "Park" }
        if name.contains("restaurant") { return "Restaurant" }
        if name.contains("temple") || name.contains("church") { return "Religious Site" }
        if name.contains("castle") || name.contains("palace") { return "Historical Site" }
        return "Tourist Attraction"
    }

    private func assignSystemImage(for category: String) -> String {
        switch category {
        case "Museum": return "building.columns.fill"
        case "Park": return "leaf.fill"
        case "Restaurant": return "fork.knife"
        case "Religious Site": return "building.2.fill"
        case "Historical Site": return "castle.fill"
        default: return "star.fill"
        }
    }

    private func generateDescription(for category: String) -> String {
        switch category {
        case "Museum":
            return "Explore fascinating exhibits and artifacts in this cultural institution."
        case "Park":
            return "A beautiful green space perfect for relaxation and outdoor activities."
        case "Restaurant":
            return "Experience local cuisine and culinary delights in this establishment."
        case "Religious Site":
            return "A sacred place of worship with significant historical and cultural importance."
        case "Historical Site":
            return "Step back in time and discover the rich history of this landmark."
        default:
            return "A popular destination worth visiting during your stay."
        }
    }
}

/// A custom map pin view for displaying a tourist destination on the map.
struct CustomMapPin: View {
    let destination: TouristDestination // The associated destination for the pin
    let isSelected: Bool // Indicates whether this pin is selected
    let action: () -> Void // Action to perform when the pin is tapped
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                // Pin icon with dynamic color and background
                Image(systemName: destination.imageSystemName)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .red : .blue)
                    .background(
                        Circle()
                            .fill(.white)
                            .frame(width: 40, height: 40)
                    )
                    .shadow(radius: 2)
                
                // Display the destination name if the pin is selected
                if isSelected {
                    Text(destination.name)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Material.ultraThinMaterial)
                                .shadow(radius: 2)
                        )
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
}

/// A loading view overlay for displaying progress and a message.
struct CustomLoadingView: View {
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.4)

            VStack(spacing: 16) {
                // Circular progress indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)

                // Loading message
                Text("Discovering Top Attractions...")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Material.ultraThinMaterial)
            )
        }
        .ignoresSafeArea()
    }
}


/// A resizable bottom sheet view with customizable content.
struct BottomSheetView<Content: View>: View {
    let maxHeight: CGFloat // Maximum height of the bottom sheet
    let minHeight: CGFloat // Minimum height of the bottom sheet
    @Binding var currentHeight: CGFloat // Binding to track the current height
    let content: Content // Customizable content of the bottom sheet

    @GestureState private var translation: CGFloat = 0 // Tracks drag translation

    // Initializer for injecting the content
    init(maxHeight: CGFloat, minHeight: CGFloat, currentHeight: Binding<CGFloat>, @ViewBuilder content: () -> Content) {
        self.maxHeight = maxHeight
        self.minHeight = minHeight
        self._currentHeight = currentHeight
        self.content = content()
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Handle for dragging
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary)
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                // Bottom sheet content
                content
                    .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(width: geometry.size.width, height: currentHeight, alignment: .top)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Material.regularMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: -2)
            )
            .frame(maxWidth: .infinity, alignment: .bottom)
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.height
                    }
                    .onChanged { value in
                        // Adjust the height based on drag gesture
                        let newHeight = currentHeight - value.translation.height
                        if newHeight < maxHeight && newHeight > minHeight {
                            currentHeight = newHeight
                        }
                    }
                    .onEnded { value in
                        // Snap to maxHeight or minHeight based on the drag position
                        let snapPoint: CGFloat
                        let midPoint = (maxHeight + minHeight) / 2

                        if currentHeight > midPoint {
                            snapPoint = maxHeight
                        } else {
                            snapPoint = minHeight
                        }

                        withAnimation(.spring()) {
                            currentHeight = snapPoint
                        }
                    }
            )
        }
    }
}


/// A list view for displaying top tourist attractions.
struct AttractionsList: View {
    let destinations: [TouristDestination] // List of destinations to display
    @Binding var selectedDestination: TouristDestination? // Currently selected destination
    let onDestinationSelect: (TouristDestination) -> Void // Action when a destination is selected

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Top Attractions")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            // Scrollable list of destinations
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(destinations) { destination in
                        EnhancedDestinationCard(
                            destination: destination,
                            isSelected: selectedDestination?.id == destination.id,
                            onSelect: { onDestinationSelect(destination) }
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
        }
    }
}


/// A detailed card view for displaying a tourist destination.
struct EnhancedDestinationCard: View {
    let destination: TouristDestination // The destination to display
    let isSelected: Bool // Whether this card is selected
    let onSelect: () -> Void // Action when the card is tapped

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    // Destination icon
                    Image(systemName: destination.imageSystemName)
                        .font(.title2)
                        .foregroundColor(.blue)

                    // Destination name and category
                    VStack(alignment: .leading) {
                        Text(destination.name)
                            .font(.headline)

                        Text(destination.category)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    // Destination rating
                    RatingView(rating: destination.rating)
                }

                // Destination description
                Text(destination.description)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}


struct RatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
            
            Text(String(format: "%.1f", rating))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.yellow.opacity(0.2))
        )
    }
}

struct EnhancedDestinationDetailView: View {
    let destination: TouristDestination
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: destination.imageSystemName)
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(spacing: 8) {
                        Text(destination.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(destination.category)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                            )
                    }
                }
                .padding()
                
                // Rating and Details
                VStack(spacing: 20) {
                    // Rating Section
                    HStack(spacing: 20) {
                        VStack {
                            Text(String(format: "%.1f", destination.rating))
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Rating")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                        
                        HStack(spacing: 2) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(destination.rating) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Material.ultraThinMaterial)
                    )
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        // Directions Button
                        Button(action: {
                            openInMaps()
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Directions")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        // Share Button
                        Button(action: {
                            shareDestination()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Description and Address
                VStack(spacing: 20) {
                    InfoSection(title: "About", content: destination.description)
                    InfoSection(title: "Address", content: destination.address)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func openInMaps() {
        let url = URL(string: "maps://?daddr=\(destination.latitude),\(destination.longitude)")
        if let url = url {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareDestination() {
        let shareText = """
            \(destination.name)
            Category: \(destination.category)
            Address: \(destination.address)
            Rating: \(String(format: "%.1f", destination.rating))
            """
        
        let av = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(av, animated: true)
        }
    }
}

struct InfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            Text(content)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Material.ultraThinMaterial)
        )
    }
}
