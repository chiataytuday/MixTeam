import SwiftUI
import Combine
import UIKit

struct EditPlayerView: View {
    static let imageIdentifiers: [ImageIdentifier] = PlayerImagesView.imageIdentifiers
    var editPlayer: ((String, ImageIdentifier) -> Void)? = nil
    @Environment(\.presentationMode) var presentation
    @Binding var playerName: String
    @Binding var imageIdentifier: ImageIdentifier
    @State private var keyboardHeight: CGFloat = 0
    @State private var isPlayerImagesPresented = false
    @State private var isAlertPresented = false

    var body: some View {
        ScrollView {
            VStack {
                title
                playerImage.frame(width: 200, height: 200)
                playerNameField
                HStack {
                    editPlayerButton
                    Button(action: cancel, label: { Text("Cancel")})
                }
            }
            .sheet(isPresented: $isPlayerImagesPresented) {
                PlayerImagesView(selectedImageIdentifier: self.$imageIdentifier)
            }
            .alert(isPresented: $isAlertPresented) { self.noNameAlert }
        }.keyboardAdaptive()
    }

    private var title: some View {
        Text(playerName)
            .font(.largeTitle)
            .padding()
    }

    private var playerImage: some View {
        Button(action: { self.isPlayerImagesPresented = true }) {
            imageIdentifier
                .image
                .resizable()
                .scaledToFit()
        }.buttonStyle(PlainButtonStyle())
    }

    private var playerNameField: some View {
        TextField("", text: $playerName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
    }

    private var editPlayerButton: some View {
        Button(action: editPlayerAction) {
            Text("Edit Player")
        }
        .padding()
    }

    private func editPlayerAction() {
        editPlayer?(playerName, imageIdentifier)
    }

    private var noNameAlert: Alert {
        Alert(
            title: Text("Give a name"),
            message: Text("Please, give a name to the player"),
            dismissButton: .cancel()
        )
    }

    private func cancel() {
        presentation.wrappedValue.dismiss()
    }
}

struct EditPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        EditPlayerView(playerName: .constant("Harry"), imageIdentifier: .constant(.harryPottar))
    }
}

class EditPlayerHostingController: UIHostingController<EditPlayerView> {
    var player: Player? = nil
    var playerName: Binding<String> { .init(
        get: { self.player?.name ?? "Error" },
        set: { _ in }
    )}
    var imageIdentifier: Binding<ImageIdentifier> { .init(
        get: { self.player?.appImage?.imageIdentifier ?? .theBotman },
        set: { _ in }
    )}

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: EditPlayerView(playerName: .constant("Error"), imageIdentifier: .constant(.theBotman)))
        rootView = EditPlayerView(
            editPlayer: editPlayer(name:imageIdentifier:),
            playerName: playerName,
            imageIdentifier: imageIdentifier
        )
        rootView.editPlayer = editPlayer(name:imageIdentifier:)
    }

    func editPlayer(name: String, imageIdentifier: ImageIdentifier) {
        let player = Player(name: name, image: UIImage(imageLiteralResourceName: imageIdentifier.rawValue).appImage)
        player.save()
        self.player = player

        // TODO: add the segue to the storyboard
        self.performSegue(withIdentifier: PlayersTableViewController.fromAddPlayerUnwindSegueIdentifier, sender: nil)
    }
}
