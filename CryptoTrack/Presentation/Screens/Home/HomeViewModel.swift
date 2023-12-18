//
//  HomeViewModel.swift
//  CryptoTrack
//
//  Created by Quentin Gaillardet on 12/12/2023.
//

import Foundation

class HomeViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    var filteredCoins: [Coin] {
       guard !searchText.isEmpty else { return coins }
       return coins.filter { coin in
           coin.name.lowercased().contains(searchText.lowercased())
       }
    }
    
    @Published var errorMessage: String?
    private var currentPage : Int = 1
    
    @Published var suggestions = ["Bitcoin", "Ethereum", "Polygon"]
    
    var filteredSuggestions: [String] {
       guard !searchText.isEmpty else { return [] }
       return suggestions.sorted().filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    @Published var searchText: String = ""
    @Published var showAlert: Bool = false

    private lazy var coinService: CoinService = { return _CoinService() }()
    
   

    init() {
        fetchCoins()
    }

    func fetchCoins() {
        errorMessage = nil
        
        Task {
            do {
                let fetchedCoins = try await coinService.fetchAllCoins(currency: .usd, sortingOption: .marketCapAsc, perPage: 20, page: currentPage, sparkLine: true)
                
                await MainActor.run {
                    self.coins = fetchedCoins
                }
            } catch let coinGeckoError as ApiServiceError {
                print("DEBUG: Error \(coinGeckoError.localizedDescription)")

                await MainActor.run {
                    self.errorMessage = coinGeckoError.localizedDescription
                    showAlert = true
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "An unexpected error occurred."
                    showAlert = true
                }
            }
        }
    }
    
    func loadMoreContentIfNeeded(currentItem : Coin) {
        if(currentItem.id == coins.last?.id){
            currentPage += 1
            Task{
                do {
                    let fetchedCoins = try await coinService.fetchAllCoins(currency: .usd, sortingOption: .marketCapAsc, perPage: 20, page: currentPage, sparkLine: true)
                    
                    await MainActor.run {
                        self.coins = self.coins + fetchedCoins
                    }
                } catch let coinGeckoError as ApiServiceError  {
                    await MainActor.run {
                        self.errorMessage = coinGeckoError.localizedDescription
                        showAlert = true
                    }
                }
            }
        }
    }
}

