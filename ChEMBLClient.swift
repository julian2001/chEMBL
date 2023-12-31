//
//  ChEMBLClient.swift
//  
//
//  Created by Julian Reyes on 12/31/23.
//


// ChEMBLClient.swift
import Foundation

struct ChEMBLClient {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchCompounds(query: String, completion: @escaping (Result<[Compound], Error>) -> Void) {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://www.ebi.ac.uk/chembl/api/data/compound?search=\(encodedQuery)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(NetworkError.httpError(httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let compounds = try JSONDecoder().decode([Compound].self, from: data)
                completion(.success(compounds))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case httpError(Int)
}
