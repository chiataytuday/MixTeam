import SwiftUI

// TODO: fix many code duplications with TeamRow
struct FirstTeamRow: View {
    let team: Team
    let callbacks: FirstTeamRow.Callbacks

    private let aboutButtonSize = CGSize(width: 60, height: 60)

    var body: some View {
        ZStack(alignment: .topTrailing) {
            card
            Button(action: callbacks.displayAbout) {
                Image(systemName: "cube.box")
                .resizable()
            }
            .frame(width: aboutButtonSize.width, height: aboutButtonSize.height)
            .buttonStyle(CommonButtonStyle(color: .gray))
            .padding()
        }
    }

    var card: some View {
        VStack {
            sectionHeader
                .font(.callout)
                .foregroundColor(Color.white)
                .padding(.top)
            ForEach(team.players) { player in
                PlayerRow(
                    player: player,
                    isInFirstTeam: true,
                    callbacks: self.playerRowCallbacks
                )
            }
            addPlayerButton
        }
        .frame(maxWidth: .infinity)
        .background(team.colorIdentifier.color)
        .modifier(AddDashedCardStyle(notchSize: aboutButtonSize + 8))
        .frame(maxWidth: .infinity)
        .padding()
    }

    // TODO: fix code duplication with TeamRow
    private var sectionHeader: some View {
        VStack {
            Text(team.name)
                .padding(.leading)
                .padding(.trailing, aboutButtonSize.width + 16)
            team.imageIdentifier.image
                .resizable()
                .renderingMode(.template)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(team.colorIdentifier.color)
                .frame(width: 50, height: 50)
                .padding()
                .background(Color.white.clipShape(Circle()))
                .padding(.bottom)
        }
    }

    private var addPlayerButton: some View {
        Button(action: callbacks.createPlayer) {
            Image(systemName: "plus")
                .frame(width: 50, height: 50)
                .background(Color.white.clipShape(Circle()))
                .foregroundColor(.gray)
                .accessibility(label: Text("Add Player"))
        }.padding()
    }
}

extension FirstTeamRow {
    struct Callbacks {
        let createPlayer: () -> Void
        let editPlayer: (Player) -> Void
        let deletePlayer: (Player) -> Void
        let moveBackPlayer: (Player) -> Void
        let displayAbout: () -> Void
    }

    private var playerRowCallbacks: PlayerRow.Callbacks {
        .init(
            edit: callbacks.editPlayer,
            delete: callbacks.deletePlayer,
            moveBack: callbacks.moveBackPlayer
        )
    }
}

private extension CGSize {
    static func + (lhs: Self, rhs: CGFloat) -> Self {
        CGSize(width: lhs.width + rhs, height: lhs.height + rhs)
    }
}

struct FirstTeamRow_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View, TeamRowPreview {
        var body: some View {
            ScrollView {
                FirstTeamRow(
                    team: Team(
                        name: "Players standing for a team with a too long text"),
                    callbacks: firstTeamDebuggableCallbacks
                )
                FirstTeamRow(
                    team: Team(
                        name: "With right to left"),
                    callbacks: firstTeamDebuggableCallbacks
                ).environment(\.layoutDirection, .rightToLeft)
                TeamRow(
                    team: Team(
                        name: "Test",
                        colorIdentifier: .red,
                        imageIdentifier: .koala
                    ),
                    isFirst: false,
                    callbacks: debuggableCallbacks
                )
            }
        }
    }
}
