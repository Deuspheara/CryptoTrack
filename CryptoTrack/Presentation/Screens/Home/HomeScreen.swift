//
//  HomeScreen.swift
//  CryptoTrack
//
//  Created by Quentin Gaillardet on 12/12/2023.
//

import SwiftUI

struct HomeScreen: View {
    @StateObject var viewModel: HomeViewModel = HomeViewModel()
    @State private var showAlert = false
    @State var selectedCoin: Coin? = nil


    var body: some View {
        NavigationSplitView(sidebar: {
            List(viewModel.filteredCoins) { coin in
                NavigationLink(destination: CoinDetail(coin: coin)) {
                    CoinRow(coin: coin)
                }
                .onAppear {
                    viewModel.loadMoreContentIfNeeded(currentItem: coin)
                }
            }
            .navigationTitle("Cryptocurrency List")
            .onChange(of: viewModel.errorMessage) {
                if viewModel.errorMessage != nil {
                   showAlert = true
               }
            }
            .alert(isPresented: $viewModel.showAlert) {
               Alert(
                   title: Text("Error"),
                   message: Text(viewModel.errorMessage ?? "An error occurred."),
                   primaryButton: .default(Text("Retry")) {
                      viewModel.fetchCoins()
                   },
                   secondaryButton: .cancel()
               )
            }
            .overlay {
               if viewModel.coins.isEmpty {
                   VStack {
                       Text("No coins available.")
                           .font(.headline)
                           .foregroundColor(.secondary)
                       Button("Retry") {
                           Task {
                              viewModel.fetchCoins()
                           }
                       }
                       .foregroundColor(.blue)
                   }
                   .padding()
               }
           }
            .searchable(text: $viewModel.searchText, suggestions: {
                ForEach(viewModel.filteredSuggestions, id: \.self) { suggestion in
                   Text(suggestion)
                     .searchCompletion(suggestion)
                 }
                .searchSuggestions(.hidden, for: .content)
            })
        },
        detail: {
            if let coin = selectedCoin {
                CoinDetail(coin: coin)
            } else {
                Text("Select a coin")
            }
        })
    }
}



struct CoinRow: View {
    let coin: Coin
   
    var body: some View {
        let lineColor: Color = {
            guard let marketCapChangePercentage24h = coin.marketCapChangePercentage24h else {
                return .blue
            }

            let insignificantThreshold: Double = 0.3

            if abs(marketCapChangePercentage24h) > insignificantThreshold {
                if marketCapChangePercentage24h > 0 {
                    return .green
                } else {
                    return .red
                }
            } else {
                return .blue
            }
        }()
        
        
        HStack {
            AsyncImage(url: URL(string: coin.image ?? ""))
            { image in
               image
                   .resizable()
                   .frame(width: 35, height: 35)
           } placeholder: {
               ProgressView()
                   .padding(8)
                   .frame(width: 35, height: 35)
           }
            VStack(alignment: .leading) {
                Text(coin.name)
                    .font(.headline)
                Text(coin.symbol)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }.padding(.leading, 8)
            Spacer()
            VStack(alignment: .trailing) {
                SparklineView(dataPoints: coin.sparklineIn7d?.price ?? [], lineColor: lineColor )
                    .padding(16)
            }
        }
        .padding()
    }
}

#Preview {
    HomeScreen()
}
