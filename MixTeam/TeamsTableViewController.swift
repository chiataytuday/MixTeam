//
//  TeamsTableViewController.swift
//  MixTeam
//
//  Created by Renaud JENNY on 27/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

private let kTeamsTableViewCellIdentifier = "teamsTableViewCellIdentifier"

class TeamsTableViewController: UITableViewController {
    var teams: [Team] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.teams = Team.loadList()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTeamsTableViewCellIdentifier, for: indexPath)

        let team = self.teams[indexPath.row]
        cell.textLabel?.text = team.name
        cell.imageView?.image = team.image?.tint(with: team.color)
        cell.backgroundColor = team.color.withAlphaComponent(0.10)
        cell.textLabel?.backgroundColor = UIColor.clear

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let team = self.teams[indexPath.row]

            guard let playersTableViewController = self.playersTableViewController else {
                // TODO: error
                return
            }
            playersTableViewController.remove(team: team)

            self.teams.remove(at: indexPath.row)
            team.delete()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        switch segue.destination {
        case let viewController as EditTeamViewController:
            if let selectedCell = sender as? UITableViewCell, let teamTableCellIndexPath = self.tableView.indexPath(for: selectedCell) {
                viewController.team = self.teams[teamTableCellIndexPath.row]
                viewController.editTeamAction = { (team: Team) in
                    self.tableView.reloadData()
                }
            }
        case let viewController as AddTeamViewController:
            viewController.addTeamAction = { (team: Team) in
                self.teams.append(team)
                self.tableView.reloadData()
            }
        default: break
        }
    }

}
