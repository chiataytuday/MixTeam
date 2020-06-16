//
//  Team.swift
//  MixTeam
//
//  Created by Renaud JENNY on 17/05/2017.
//  Copyright © 2017 Renaud JENNY. All rights reserved.
//

import UIKit

struct Team: Codable {
    var id = UUID()
    var name: String = ""
    var colorIdentifier: ColorIdentifier = .gray
    var imageIdentifier: ImageIdentifier = .unknown
    var players: [Player] = []

    init(name: String, colorIdentifier: ColorIdentifier, imageIdentifier: ImageIdentifier) {
        self.name = name
        self.colorIdentifier = colorIdentifier
        self.imageIdentifier = imageIdentifier
    }
}

struct Teams: Codable {
    var teams: [Team]
}

// MARK: - Persistance

extension Team {
    static let teamsResourcePath = "teams"
    static let teamsJSONStringKey = "teamsJSONString"
    
    func save() {
        var teams = Team.loadList()
        teams.append(self)
        Team.save(teams: teams)
        NotificationCenter.default.post(name: NSNotification.Name.TeamDidAdded, object: self)
    }

    static func save(teams: [Team]) {
        guard let data = try? JSONEncoder().encode(Teams(teams: teams)),
            let jsonString = String(data: data, encoding: .utf8) else {
                fatalError("Cannot save Teams JSON")
        }

        UserDefaults.standard.set(jsonString, forKey: Team.teamsJSONStringKey)
        NotificationCenter.default.post(name: .TeamsUpdated, object: teams)
    }

    static func loadList() -> [Team] {
        guard let teamsJSONString = UserDefaults.standard.string(forKey: Team.teamsJSONStringKey),
            let jsonData = teamsJSONString.data(using: .utf8),
            let teamsContainer = try? JSONDecoder().decode(Teams.self, from: jsonData) else {
                return []
        }

        return teamsContainer.teams
    }

    func delete() {
        var teams = Team.loadList()
        teams = teams.filter { $0 != self }

        Team.save(teams: teams)
        NotificationCenter.default.post(name: NSNotification.Name.TeamDidDeleted, object: self)
    }

    func update() {
        var teams = Team.loadList()
        guard let index = teams.firstIndex(where: { $0 == self }) else {
            // Team not exist yet, save it instead
            self.save()
            return
        }

        teams[index] = self
        Team.save(teams: teams)
        NotificationCenter.default.post(name: NSNotification.Name.TeamDidUpdated, object: self)
    }
}

extension Team: Identifiable, Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    static func == (lhs: Team, rhs: Team) -> Bool {
        lhs.id == rhs.id
    }
}

extension Notification.Name {
    static let TeamDidAdded = Notification.Name("TeamDidAdded")
    static let TeamDidDeleted = Notification.Name("TeamDidDeleted")
    static let TeamDidUpdated = Notification.Name("TeamDidUpdated")
    static let TeamsUpdated = Notification.Name("TeamsUpdated")
}
