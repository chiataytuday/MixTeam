import SwiftUI

struct PlayersView: View {
    static let playersColorResetDelay: DispatchTimeInterval = .milliseconds(400)
    static let shadowColor = Color(.sRGBLinear, white: 0, opacity: 0.25)
    @EnvironmentObject var teamsStore: TeamsStore
    @State private var editedPlayer: Player?
    @State private var presentedAlert: PresentedAlert?
    var presentedAlertBinding: Binding<PresentedAlert?> { $presentedAlert }

    var body: some View {
        NavigationView {
            playersView
        }
    }

    private var playersView: some View {
        ScrollView {
            teamRow(teams.first ?? Team())
            mixTeamButton
            ForEach(teams.dropFirst(), content: teamRow)
            addTeamButton
        }
        .animation(.default)
        .alert(item: $presentedAlert, content: alert(for:))
        .sheet(item: $editedPlayer, content: edit(player:))
        .navigationBarTitle("Players")
    }

    private func teamRow(_ team: Team) -> some View {
        VStack {
            sectionHeader(team: team)
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEach(team.players) { player in
                PlayerRow(
                    player: player,
                    isInFirstTeam: self.teams.first == team,
                    edit: { self.editedPlayer = player },
                    delete: { self.deletePlayer(player) },
                    moveBack: { self.moveBack(player: player) }
                )
            }
            if isFirstTeam(team) {
                addPlayerButton
            }
        }
        .background(team.colorIdentifier.color)
        .modifier(AddDashedCardStyle())
        .frame(maxWidth: .infinity)
        .padding()
    }

    private func sectionHeader(team: Team) -> some View {
        VStack {
            Text(team.name).padding([.leading, .trailing])
            team.imageIdentifier.image
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(team.colorIdentifier.color)
                .frame(width: 50, height: 50)
                .padding()
                .background(
                    Color.white
                        .clipShape(Circle())
                )
                .padding(.bottom)
        }.frame(maxWidth: .infinity)
    }

    private var addPlayerButton: some View {
        NavigationLink(destination: AddPlayerView(createPlayer: createPlayer), label: {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .background(Color.white.clipShape(Circle()))
                .foregroundColor(.gray)
                .accessibility(label: Text("Add Player"))
            }).padding()
    }

    private var mixTeamButton: some View {
        Button(action: mixTeam) {
            HStack {
                Image(systemName: "shuffle")
                Text("Mix Team")
            }
        }
        .buttonStyle(MixTeamButtonStyle())
        .frame(height: 50)
        .shadow(
            color: Self.shadowColor,
            radius: 3, x: -2, y: 2
        )
        .padding([.leading, .trailing])
        .accessibility(label: Text("Mix Team"))
    }

    private var addTeamButton: some View {
        NavigationLink(destination: AddTeamView(createTeam: createTeam), label: {
            HStack {
                Image(systemName: "plus")
                Text("Add a new Team")
            }.frame(maxWidth: .infinity)
        })
            .foregroundColor(Color.white)
            .frame(height: 50)
            .background(Color.red)
            .modifier(AddDashedCardStyle())
            .padding()
            .accessibility(label: Text("Add Team"))
    }
}

// MARK: Players Logic
extension PlayersView: PlayersLogic {
    private func edit(player: Player) -> some View {
        EditPlayerView(player: player, editPlayer: editPlayer)
    }
}

// MARK: Teams Logic
extension PlayersView: TeamsLogic { }

// MARK: PresentedAlert
extension PlayersView {
    enum PresentedAlert: Identifiable {
        case notEnoughTeams

        var id: Int { self.hashValue }
    }

    private func alert(for identifier: PresentedAlert) -> Alert {
        Alert(title: Text("Couldn't Mix Team with less than 2 teams. Go create some teams :)"))
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayersView()
                .environmentObject(TeamsStore())
            PlayersView()
                .environmentObject(TeamsStore())
                .environment(\.colorScheme, .dark)
        }
    }
}
