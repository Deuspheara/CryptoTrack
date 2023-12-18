//
//  CoinService.swift
//  CryptoTrack
//
//  Created by Quentin Gaillardet on 12/12/2023.
//

import Foundation


internal protocol CoinService: AnyObject {
    func fetchAllCoins(currency: Currency, sortingOption: SortingOption, perPage: Int, page: Int, sparkLine: Bool
    ) async throws -> [Coin]
}

internal final class _CoinService: CoinService {
    
    private enum Constants {
        static let coinGeckoDomain = "https://api.coingecko.com/api/v3"
        static let coinsEndpoint = "coins"
    }
    
    func fetchAllCoins(
        currency: Currency = Currency.usd,
        sortingOption: SortingOption = SortingOption.marketCapAsc,
        perPage: Int = 10,
        page: Int = 1,
        sparkLine: Bool = true
    ) async throws -> [Coin] {
        
        let sparkLineString = sparkLine ? "true" : "false"
        guard let url = URL(string: "\(Constants.coinGeckoDomain)/\(Constants.coinsEndpoint)/markets?vs_currency=\(currency.rawValue)&order=\(sortingOption)&per_page=\(perPage)&page=\(page)&sparkline=\(sparkLineString)&locale=en") else {
            throw ApiServiceError.invalidURL
        }
        print("DEBUG: \(url)")

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Print the response status code
            if let httpResponse = response as? HTTPURLResponse {
                print("DEBUG: \(httpResponse.statusCode)")
                guard (200...430).contains(httpResponse.statusCode) else {
                     throw ApiServiceError.invalidStatusCode(httpResponse.statusCode)
                }
            }

            // Decode the data
            do {
                let coins = try JSONDecoder().decode([Coin].self, from: data)
                return coins
            } catch {
                throw ApiServiceError.decodingError(error)
            }
        } catch {
            // Print any error that occurs during the process
            print("DEBUG: Error fetching or decoding data: \(error)")
            throw ApiServiceError.networkError(error)
        }
    }
}


