import SwiftUI
import Combine

protocol TeamsLogic {
    var teamsStore: TeamsStore { get }
    var teamsList: ArraySlice<Team> { get }

    func createTeam(_ team: Team)
    func editTeam(_ team: Team)
    func deleteTeam(_ team: Team)
    // TODO: at the end remove deleteTeam(atOffsets offsets:)
    func deleteTeam(atOffsets offsets: IndexSet)
    func isFirstTeam(_ team: Team) -> Bool
}

extension TeamsLogic {
    var teamsList: ArraySlice<Team> { teamsStore.teams.dropFirst() }

    func createTeam(_ team: Team) {
        teamsStore.teams.append(team)
    }

    func deleteTeam(atOffsets offsets: IndexSet) {
        // As the real first team is not displayed. The real index is offset + 1
        let index = (offsets.first ?? 0) + 1
        let playersInDeletedTeam = teamsStore.teams[index].players
        teamsStore.teams[0].players.append(contentsOf: playersInDeletedTeam)

        teamsStore.teams.remove(at: index)
    }

    func deleteTeam(_ team: Team) {
        guard let index = teamsStore.teams.firstIndex(of: team) else { return }
        guard index > 0 else { return }

        let playersInDeletedTeam = teamsStore.teams[index].players
        teamsStore.teams[0].players.append(contentsOf: playersInDeletedTeam)

        teamsStore.teams.remove(at: index)
    }

    func editTeam(_ team: Team) {
        guard let teamIndex = teamsStore.teams.firstIndex(of: team) else {
            return
        }
        teamsStore.teams[teamIndex] = team
    }

    func isFirstTeam(_ team: Team) -> Bool { teamsStore.teams.first == team }
}
