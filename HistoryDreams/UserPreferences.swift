import Foundation

struct UserPreferences: Codable {
    var volume: Float = 1.0
    var fadeOutEnabled: Bool = true
    var fadeOutDuration: Int = 30 // seconds
    
    static func load() -> UserPreferences {
        if let data = UserDefaults.standard.data(forKey: "UserPreferences"),
           let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) {
            return preferences
        }
        return UserPreferences()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: "UserPreferences")
        }
    }
} 