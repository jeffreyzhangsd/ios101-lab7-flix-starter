//
//  Movie.swift
//  ios101-lab6-flix
//

import Foundation

struct MovieFeed: Decodable {
    let results: [Movie]
}

struct Movie: Codable, Equatable {
    let title: String
    let overview: String
    let posterPath: String? // Path used to create a URL to fetch the poster image

    // MARK: Additional properties for detail view
    let backdropPath: String? // Path used to create a URL to fetch the backdrop image
    let voteAverage: Double?
    let releaseDate: Date?

    // MARK: ID property to use when saving movie
    let id: Int

    // MARK: Custom coding keys
    // Allows us to map the property keys returned from the API that use underscores (i.e. `poster_path`)
    // to a more "swifty" lowerCamelCase naming (i.e. `posterPath` and `backdropPath`)
    enum CodingKeys: String, CodingKey {
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case id
    }
}

extension Movie {
    // The "Favorites" key: a computed property that returns a String.
    //    - Use when saving/retrieving or removing from UserDefaults
    //    - `static` means this property is "Type Property" (i.e. associated with the Movie "type", not any particular movie instance)
    //    - We can access this property anywhere like this... `Movie.favoritesKey` (i.e. Type.property)
    
    static var favoritesKey: String {
        return "Favorites"
    }

    // Save an array of favorite movies to UserDefaults.
    //    - Similar to the favoritesKey, we add the `static` keyword to make this a "Type Method".
    //    - We can call it from anywhere by calling it on the `Movie` type.
    //    - ex: `Movie.save(favoriteMovies, forKey: favoritesKey)`
    
    static func save(_ movies: [Movie], forKey key: String) {
        
        // 1. Create an instance of UserDefaults
        let defaults = UserDefaults.standard
        
        // 2. Try to encode the array of `Movie` objects to `Data`
        let encodedData = try! JSONEncoder().encode(movies)
        
        // 3. Save the encoded movie `Data` to UserDefaults
        defaults.set(encodedData, forKey: key)
    }

    // Get the array of favorite movies from UserDefaults
    //    - Again, a static "Type method" we can call anywhere like this...`Movie.getMovies(forKey: favoritesKey)`
    
    static func getMovies(forKey key: String) -> [Movie] {
        // 1. Create an instance of UserDefaults
        let defaults = UserDefaults.standard
        
        // 2. Get any favorite movies `Data` saved to UserDefaults (if any exist)
        if let data = defaults.data(forKey: key) {
            
            // 3. Try to decode the movie `Data` to `Movie` objects
            let decodedMovies = try! JSONDecoder().decode([Movie].self, from: data)
            
            // 4. If 2-3 are successful, return the array of movies
            return decodedMovies
        } else {
            
            // 5. Otherwise, return an empty array
            return []
        }
    }
    
    // Adds the movie to the favorites array in UserDefaults.
    
    func addToFavorites() {
        
        // 1. Get all favorite movies from UserDefaults
        //    - We make `favoriteMovies` a `var` so we'll be able to modify it when adding another movie
        var favoriteMovies = Movie.getMovies(forKey: Movie.favoritesKey)
        
        // 2. Add the movie to the favorite movies array
        //   - Since this method is available on "instances" of a movie, we can reference the movie this method is being called on using `self`.
        favoriteMovies.append(self)
        
        // 3. Save the updated favorite movies array
        Movie.save(favoriteMovies, forKey: Movie.favoritesKey)
    }

    // Removes the movie from the favorites array in UserDefaults
    
    func removeFromFavorites() {
        
        // 1. Get all favorite movies from UserDefaults
        var favoriteMovies = Movie.getMovies(forKey: Movie.favoritesKey)
        
        // 2. remove all movies from the array that match the movie instance this method is being called on (i.e. `self`)
        //   - The `removeAll` method iterates through each movie in the array and passes the movie into a closure where it can be used to determine if it should be removed from the array.
        favoriteMovies.removeAll { movie in
            
            // 3. If a given movie passed into the closure is equal to `self` (i.e. the movie calling the method) we want to remove it. Returning a `Bool` of `true` removes the given movie.
            
            // make movie Equatable first
            return self == movie
        }
        
        // 4. Save the updated favorite movies array.
        Movie.save(favoriteMovies, forKey: Movie.favoritesKey)
    }
}
