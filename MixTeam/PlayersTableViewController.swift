//
//  PlayersTableViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 07/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

private let kPlayersTableViewCellIdentifier = "playersTableViewCellIdentifier"
private let kDispatchPlayerTime = DispatchTimeInterval.milliseconds(200)

class PlayersTableViewController: UITableViewController {
    var teams: [Team] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let firstTeam = Team(name: NSLocalizedString("Players standing for a team", comment: ""), color: UIColor.gray)
        firstTeam.players = Player.players
        self.teams.append(firstTeam)
        self.teams.append(contentsOf: Team.teams)

        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.teams.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams[section].players.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.teams[section].name
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kPlayersTableViewCellIdentifier, for: indexPath)

        let team = self.teams[indexPath.section]
        let player = team.players[indexPath.row]

        cell.textLabel?.text = player.name
        cell.imageView?.image = player.image?.tint(with: team.color)

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch indexPath.section {
            case 0:
                // If the player was not in a team, remove it definitively
                self.teams[indexPath.section].players.remove(at: indexPath.row)
                Player.players.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            default:
                let player = self.teams[indexPath.section].players[indexPath.row]
                // Move this player to player whitout teams
                self.teams.first?.players.append(player)
                self.teams[indexPath.section].players.remove(at: indexPath.row)
            }
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editPlayerViewController = segue.destination as? EditPlayerViewController, let selectedCell = sender as? UITableViewCell, let playerTableCellIndexPath = self.tableView.indexPath(for: selectedCell) {
            editPlayerViewController.player = self.teams[playerTableCellIndexPath.section].players[playerTableCellIndexPath.row]

            editPlayerViewController.editPlayerAction = { (player: Player) in
                self.tableView.reloadData()
            }
        }

        if let addPlayerViewController = segue.destination as? AddPlayerViewController {
            addPlayerViewController.addPlayerAction = { (player: Player) in
                guard let firstTeam = self.teams.first else {
                    return
                }
                firstTeam.players.append(player)
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func mixTeam() {
        // TODO: check if there is more than 2 teams
        guard self.teams.count > 2 else {
            // TODO: Hint message
            return
        }

        guard let firstTeam = self.teams.first else {
            // TODO Throw error
            fatalError()
        }

        // First move all players back if needed
        for team in self.teams where team != self.teams.first {
            for player in team.players {
                self.move(player: player, from: team, to: firstTeam)
            }
        }

        // Dispatch players
        // To get animation effect, delay each move animation by kDispatchPlayerTime milliseconds
        var deadline: DispatchTime = .now()

        var teamHandicaps: [Team: Int] = [:]
        for team in teams where team != self.teams.first {
            teamHandicaps[team] = 0
            team.players.forEach {
                teamHandicaps[team]? += $0.handicap
            }
        }

        var playersTotalHandicap = 0
        self.teams.forEach { $0.players.forEach { playersTotalHandicap += $0.handicap }}

        for team in self.teams {
            for player in team.players {
                deadline = deadline + kDispatchPlayerTime
                let toTeam = self.pseudoRandomTeam(teamHandicaps: teamHandicaps, playersTotalHandicap: playersTotalHandicap)
                teamHandicaps[team]? -= player.handicap
                teamHandicaps[toTeam]? += player.handicap
                if team != toTeam {
                    DispatchQueue.main.asyncAfter(deadline: deadline) {
                        self.move(player: player, from: team, to: toTeam)
                    }
                }
            }
        }
    }

    func move(player: Player, from fromTeam: Team, to toTeam: Team) {
        guard let originPlayerIndex = fromTeam.players.index(where: { $0.id == player.id }),
            let originTeamSection = self.teams.index(where: { $0 == fromTeam }),
            let destinationTeamSection = self.teams.index(where: { $0 == toTeam }) else {
            return
        }
        let originIndexPath = IndexPath(row: originPlayerIndex, section: originTeamSection)
        let destinationIndexPath = IndexPath(row: toTeam.players.count, section: destinationTeamSection)

        toTeam.players.append(player)
        fromTeam.players.remove(at: originPlayerIndex)

        player.image = player.image?.tint(with: toTeam.color)

        self.tableView.moveRow(at: originIndexPath, to: destinationIndexPath)
        self.tableView.reloadRows(at: [destinationIndexPath], with: .automatic)
    }

    func pseudoRandomTeam(teamHandicaps: [Team: Int], playersTotalHandicap: Int) -> Team {
        // First, add a player in each team if there is no one yet
        let teamsWithoutPlayers = teamHandicaps.filter({ $0.value <= 0 })
        if teamsWithoutPlayers.count > 0 {
            return teamsWithoutPlayers[Int(arc4random_uniform(UInt32(teamsWithoutPlayers.count)))].key
        }

        let handicapAverage = playersTotalHandicap / (self.teams.count - 1)

        // Choose only teams that total handicap is under the average
        var unbalancedTeams = teamHandicaps.filter({ $0.value < handicapAverage })

        return unbalancedTeams[Int(arc4random_uniform(UInt32(unbalancedTeams.count)))].key
    }
}
