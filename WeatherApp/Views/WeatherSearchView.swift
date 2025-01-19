//
//  WeatherSearchView.swift
//  WeatherApp
//
//  Created by Sandaru Vithanage on 2024-12-25.
//

import SwiftUI

/// A view that allows users to search for cities and display weather information.
/// It also provides a favorites section for quick access to saved locations.
struct WeatherSearchView: View {
        
    // MARK: - Binding Properties
    
    /// The currently selected city for displaying detailed weather information.
    @Binding var selectedCity: LocationModel?
    
    /// The currently selected tab (0: Weather, 1: Map, 2: Search).
    @Binding var selectedTab: Int
    
    // MARK: - State Properties
    
    /// The current text entered by the user in the search bar.
    @State private var searchText: String = ""
    
    /// The list of search results returned after performing a city search.
    @State private var searchResults: [LocationModel] = []
    
    /// Indicates whether a search operation is in progress.
    @State private var isSearching = false
    
    /// Indicates whether the search bar is being edited.
    @State private var isEditing = true
    
    /// Observed object for managing weather data and application state.
    @ObservedObject var viewModel: WeatherViewModel

    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Custom search bar component with callbacks for search and clear actions
            SearchBar(
                searchText: $searchText,
                isEditing: $isEditing,
                onSearch: performSearch,
                onClear: {
                    searchText = ""           // Clear search text
                    searchResults = []        // Clear search results
                }
            )
            .padding()

            // ScrollView to display favorites or search results
            ScrollView {
                VStack(spacing: 16) {
                    
                    // Display favorites section when there is no search text
                    if !viewModel.favorites.isEmpty && searchText.isEmpty {
                        ForEach(viewModel.favorites, id: \.id) { location in
                            favoriteCard(for: location) // Show each favorite as a card
                        }
                    }
                    
                    // Display search results when search text is not empty
                    if !searchText.isEmpty {
                        if isSearching {
                            // Show loading indicator while searching
                            LoadingCitiesView()
                        } else if searchResults.isEmpty {
                            // Show empty state when no results are found
                            EmptyResultsView()
                        } else {
                            // Display list of search results
                            ForEach(searchResults, id: \.id) { location in
                                LocationCell(location: location) {
                                    selectedCity = location   // Set the selected city
                                    selectedTab = 0           // Switch to the weather tab
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensures ScrollView takes up remaining space
        }
        .navigationTitle("Weather") // Set navigation bar title
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Helper Method
    
    /// Creates a favorite card for a given location.
    /// - Parameter location: The location to be displayed as a favorite card.
    @ViewBuilder
    private func favoriteCard(for location: LocationModel) -> some View {
        FavoriteCardView(location: location, viewModel: viewModel) {
            selectedCity = location   // Set the selected city
            selectedTab = 0           // Switch to the weather tab
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .swipeActions(edge: .trailing) {
            // Swipe-to-delete action for removing a favorite
            Button(role: .destructive) {
                viewModel.removeFavorite(location) // Remove the location from favorites
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }

    // MARK: - Search Function
    
    /// Performs a city search based on the current search text.
    private func performSearch() {
        guard !searchText.isEmpty else { return } // Ensure search text is not empty
        
        isSearching = true
        Task {
            do {
                // Fetch location data using GeoService
                let results = try await GeoService().fetchLocation(for: searchText)
                searchResults = results
            } catch {
                // Handle errors during fetching
                print("Failed to fetch location data: \(error.localizedDescription)")
            }
            isSearching = false // Reset searching state
        }
    }
}

// MARK: - SearchBar View

/// An enhanced search bar component with error handling and user feedback
struct SearchBar: View {
    // MARK: - Properties
    @Binding var searchText: String
    @Binding var isEditing: Bool
    @FocusState private var isSearchFieldFocused: Bool
    
    // State management
    @State private var isLoading: Bool = false
    @State private var error: SearchError? = nil
    @State private var showError: Bool = false
    @State private var lastSearchTime: Date? = nil
    
    @AppStorage("recentSearches") private var recentSearches: [String] = []
    
    
    // Constants
    private let maxRecentSearches = 5
    private let debounceInterval: TimeInterval = 0.5
    private let minimumSearchInterval: TimeInterval = 1.0
    private let maxSearchLength = 50
    
    // Completion handlers
    let onSearch: () -> Void
    let onClear: () -> Void
    let onError: ((SearchError) -> Void)?
    
    // MARK: - Initialization
    init(searchText: Binding<String>,
         isEditing: Binding<Bool>,
         onSearch: @escaping () -> Void,
         onClear: @escaping () -> Void,
         onError: ((SearchError) -> Void)? = nil) {
        self._searchText = searchText
        self._isEditing = isEditing
        self.onSearch = onSearch
        self.onClear = onClear
        self.onError = onError
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                searchField
                cancelButton
            }
            
            // Error Message
            if let error = error {
                errorView(error)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Recent Searches
            if isEditing && error == nil {
                recentSearchesSection
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: error != nil)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isEditing)
        .alert("Search Error", isPresented: $showError, presenting: error) { error in
            Button("OK") {
                self.error = nil
            }
            if error.recoverySuggestion != nil {
                Button("Try Again") {
                    self.error = nil
                    performSearch()
                }
            }
        } message: { error in
            Text(error.recoverySuggestion ?? error.errorDescription ?? "Unknown error")
        }
    }
    
    // MARK: - Search Field
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(error != nil ? .red : .gray)
                .padding(.leading, 8)
            
            TextField("Search for a city...", text: $searchText)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onChange(of: searchText) { newValue in
                    validateAndDebounceSearch(newValue)
                }
                .onSubmit(performSearch)
            
            Group {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .transition(.opacity)
                } else if !searchText.isEmpty {
                    Button(action: clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(error != nil ? .red : .gray)
                    }
                    .transition(.opacity)
                }
            }
            .frame(width: 30)
            .padding(.trailing, 8)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: 1)
        )
    }
    
    // MARK: - Error View
    private func errorView(_ error: SearchError) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(error.errorDescription ?? "Unknown error")
                .font(.subheadline)
                .foregroundColor(.red)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Views
    private var cancelButton: some View {
        Group {
            if isEditing {
                Button("Cancel") {
                    withAnimation {
                        clearSearch()
                        isEditing = false
                        isSearchFieldFocused = false
                        error = nil
                    }
                }
                .foregroundColor(.blue)
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
    }
    
    private var recentSearchesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !recentSearches.isEmpty {
                HStack {
                    Text("Recent Searches")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Spacer()
                    Button("Clear All") {
                        withAnimation {
                            recentSearches.removeAll()
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(recentSearches, id: \.self) { search in
                            recentSearchButton(for: search)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Computed Properties
    private var shadowColor: Color {
        if error != nil {
            return .red.opacity(0.2)
        } else if isEditing {
            return .blue.opacity(0.2)
        }
        return .clear
    }
    
    private var borderColor: Color {
        if error != nil {
            return .red.opacity(0.5)
        } else if isEditing {
            return .blue.opacity(0.3)
        }
        return .clear
    }
    
    // MARK: - Helper Methods
    private func validateAndDebounceSearch(_ newValue: String) {
        // Reset error state when user starts typing
        error = nil
        
        // Validate search text
        do {
            try validateSearchText(newValue)
            debounceSearch()
        } catch let validationError as SearchError {
            error = validationError
            onError?(validationError)
        } catch {
            onError?(.invalidCharacters)
        }
    }
    
    private func validateSearchText(_ text: String) throws {
        // Check for empty query
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw SearchError.emptyQuery
        }
        
        // Check for invalid characters
        let allowedCharacterSet = CharacterSet.letters.union(.whitespaces)
        guard text.unicodeScalars.allSatisfy({ allowedCharacterSet.contains($0) }) else {
            throw SearchError.invalidCharacters
        }
    }
    
    private func debounceSearch() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval) {
            isLoading = false
            if !searchText.isEmpty {
                performSearch()
            }
        }
    }
    
    private func performSearch() {
        do {
            // Validate the input
            try validateSearchText(searchText)
            
            // Proceed with the search if validation passes
            lastSearchTime = Date()
            withAnimation {
                if !recentSearches.contains(searchText) {
                    recentSearches.insert(searchText, at: 0)
                    if recentSearches.count > maxRecentSearches {
                        recentSearches.removeLast()
                    }
                }
            }
            
            onSearch()
            isEditing = false
            isSearchFieldFocused = false
            
        } catch let searchError as SearchError {
            // Handle validation errors
            error = searchError
            onError?(searchError)
            showError = true
        } catch {
            onError?(.invalidCharacters)
            showError = true
        }
    }
    
    private func clearSearch() {
        searchText = ""
        error = nil
        onClear()
    }
    
    private func recentSearchButton(for search: String) -> some View {
        Button(action: {
            searchText = search
            performSearch()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                Text(search)
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray5))
            .cornerRadius(16)
        }
        .contextMenu {
            Button(role: .destructive) {
                withAnimation {
                    recentSearches.removeAll { $0 == search }
                }
            } label: {
                Label("Remove", systemImage: "trash")
            }
        }
    }
}
// MARK: - Supporting Views

/// A view that displays a loading indicator and message while searching.
struct LoadingCitiesView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Searching cities...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A view that displays an empty results message when no cities are found.
struct EmptyResultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("No cities found")
                .font(.headline)
            Text("Try searching for another city")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// A reusable cell view displaying a city's name and country, with an arrow indicator.
struct LocationCell: View {
    let location: LocationModel // The location to be displayed
    let onTap: () -> Void       // Callback for when the cell is tapped
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                    Text(location.country)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.system(size: 14, weight: .semibold))
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color(.systemGray4).opacity(0.5),
                   radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 4)
    }
}

/// Enum defining possible search errors
enum SearchError: Error, LocalizedError {
    case emptyQuery
    case invalidCharacters
    case networkError(Error)
    case tooManyRequests
    case serverError
    
    var errorDescription: String? {
        switch self {
        case .emptyQuery:
            return "Please enter a search term"
        case .invalidCharacters:
            return "Search contains invalid characters"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .tooManyRequests:
            return "Too many searches. Please try again in a moment"
        case .serverError:
            return "Server error. Please try again later"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .emptyQuery:
            return "Enter a city name to search"
        case .invalidCharacters:
            return "Use only letters, numbers, and spaces"
        case .networkError:
            return "Check your internet connection and try again"
        case .tooManyRequests:
            return "Wait a few seconds before searching again"
        case .serverError:
            return "Our servers are experiencing issues. Try again later"
        }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

