import Foundation

struct ProfileEdited: Encodable, Equatable {
    let name: String
    let description: String
    let website: String
}

extension ProfileEdited {
    init(from: Profile) {
        self.name = from.name
        self.description = from.description
        self.website = from.website
    }
}
