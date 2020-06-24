import SwiftUI

final class TeamsStore: ObservableObject {
    static let teamsKey = "teams"
    @Published var teams: [Team] {
        didSet { save() }
    }

    init() {
        guard let data = UserDefaults.standard.data(forKey: Self.teamsKey) else {
            teams = .exampleTeam
            return
        }

        let savedTeams = try? JSONDecoder().decode([Team].self, from: data)
        teams = savedTeams ?? .exampleTeam
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(teams) else { return }
        UserDefaults.standard.set(data, forKey: Self.teamsKey)
    }
}

extension Array where Element == Team {
    static let exampleTeam: Self = {
        var playersStandingTeam = Team(
            name: "Players standing for a team",
            colorIdentifier: .gray, imageIdentifier: .unknown
        )
        playersStandingTeam.players = [
            Player(name: "Lara", imageIdentifier: .laraCraft),
            Player(name: "Harry", imageIdentifier: .harryPottar)
        ]
        var koalaTeam = Team(name: "Red Koala", colorIdentifier: .red, imageIdentifier: .koala)
        koalaTeam.players = [Player(name: "Vador", imageIdentifier: .darkVadir)]
        return [
            playersStandingTeam,
            koalaTeam,
            Team(name: "Purple Elephant", colorIdentifier: .purple, imageIdentifier: .elephant)
        ]
    }()
}
