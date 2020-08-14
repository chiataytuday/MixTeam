import SwiftUI

struct EditTeamView: View {
    @Environment(\.presentationMode) var presentation
    @Binding var team: Team
    @State private var animateSplashGrowing: Bool = false
    @State private var animateSplashDripping: Bool = false

    var body: some View {
        VStack {
            teamNameField
            colorPicker
            ImagePicker(team: team, selection: $team.imageIdentifier, type: .team)

        }
        .background(color.edgesIgnoringSafeArea(.all))
        .onAppear {
            withAnimation(Animation.easeIn(duration: 0.4)) {
                self.animateSplashGrowing = true
            }
            withAnimation(Animation.easeInOut(duration: 2).delay(0.4)) {
                self.animateSplashDripping = true
            }
        }
    }

    private var teamNameField: some View {
        HStack {
            TextField("Edit", text: $team.name)
                .foregroundColor(Color.white)
                .font(.title)
                .padding()
                .background(color)
                .modifier(AddDashedCardStyle())
                .padding(.leading)
            doneButton.padding(.trailing)
        }.padding(.top)
    }

    private var doneButton: some View {
        Button(action: { self.presentation.wrappedValue.dismiss() }, label: {
            Image(systemName: "checkmark")
                .foregroundColor(color)
                .padding()
                .background(Splash2())
                .foregroundColor(.white)
        }).accessibility(label: Text("Done"))
    }

    private var colorPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(ColorIdentifier.allCases) { colorIdentifier in
                    Button(action: { self.team.colorIdentifier = colorIdentifier }, label: {
                        colorIdentifier.color
                            .frame(width: 50, height: 50)
                            .clipShape(Splash(animatableData: self.animateSplashDripping ? 1 : 0))
                            .scaleEffect(self.animateSplashGrowing ? 1 : 0.1)
                    }).accessibility(label: Text("\(colorIdentifier.name) color"))
                }
            }
        }
        .padding()
        .background(team.colorIdentifier.color.brightness(-0.2))
        .modifier(AddDashedCardStyle())
        .padding()
    }

    var color: Color { team.colorIdentifier.color }
}

struct EditTeamView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    struct Preview: View {
        @State private var team = Team(
            name: "Test",
            colorIdentifier: .red,
            imageIdentifier: .koala
        )

        var body: some View {
            EditTeamView(team: $team)
        }
    }
}

struct EditTeamViewInteractive_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .environmentObject(TeamsStore())
    }

    struct Preview: View, TeamRowPreview {
        @EnvironmentObject var teamsStore: TeamsStore
        @State private var isEdited = false
        private var team: Team { teamsStore.teams[1] }

        var body: some View {
            TeamRow(team: team, callbacks: callbacks)
                .sheet(isPresented: $isEdited) {
                    EditTeamView(team: self.$teamsStore.teams[1])
            }
        }

        private var callbacks: TeamRow.Callbacks {
            .init(
                editTeam: { _ in self.isEdited = true },
                deleteTeam: debuggableCallbacks.deleteTeam,
                editPlayer: debuggableCallbacks.editPlayer,
                moveBackPlayer: debuggableCallbacks.moveBackPlayer
            )
        }
    }
}
