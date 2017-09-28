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

            // TODO: Remove team from players table view

            self.teams.remove(at: indexPath.row)
            team.delete()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let editTeamViewController = segue.destination as? EditTeamViewController,
            let selectedCell = sender as? UITableViewCell, let teamTableCellIndexPath = self.tableView.indexPath(for: selectedCell) {
            editTeamViewController.team = self.teams[teamTableCellIndexPath.row]
        }
    }
}
