import Foundation

struct Story: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let narrator: String
    var duration: TimeInterval
    let category: Category
    let timePeriod: String
    let region: String
    let thumbnailURL: URL?
    let audioURL: URL?
    var lastPlayedDate: Date?
    var progress: Double?
    
    enum Category: String, Codable, CaseIterable {
        case ancientCivilizations = "Ancient Civilizations"
        case medievalTimes = "Medieval Times"
        case renaissance = "Renaissance"
        case industrialRevolution = "Industrial Revolution"
        case modernHistory = "Modern History"
        case mythology = "Mythology"
    }
    
    init(id: UUID = UUID(), 
         title: String,
         description: String,
         narrator: String,
         duration: TimeInterval,
         category: Category,
         timePeriod: String,
         region: String,
         thumbnailURL: URL? = nil,
         audioURL: URL? = nil,
         lastPlayedDate: Date? = nil,
         progress: Double? = nil) {
        self.id = id
        self.title = title
        self.description = description
        self.narrator = narrator
        self.duration = duration
        self.category = category
        self.timePeriod = timePeriod
        self.region = region
        self.thumbnailURL = thumbnailURL
        self.audioURL = audioURL
        self.lastPlayedDate = lastPlayedDate
        self.progress = progress
    }
}

// MARK: - Convenience Methods
extension Story {
    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
    
    var isPartiallyPlayed: Bool {
        progress != nil && progress! > 0 && progress! < 1
    }
    
    var isCompleted: Bool {
        progress != nil && progress! >= 1
    }
} 