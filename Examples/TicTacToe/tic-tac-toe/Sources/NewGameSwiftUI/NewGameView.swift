import ComposableArchitecture
import GameCore
import GameSwiftUI
import NewGameCore
import SwiftUI

public struct NewGameView: View {
  let store: StoreOf<NewGame>

  struct ViewState: Equatable {
    var isGameActive: Bool
    var isLetsPlayButtonDisabled: Bool
    var oPlayerName: String
    var xPlayerName: String

    init(state: NewGame.State) {
      self.isGameActive = state.game != nil
      self.isLetsPlayButtonDisabled = state.oPlayerName.isEmpty || state.xPlayerName.isEmpty
      self.oPlayerName = state.oPlayerName
      self.xPlayerName = state.xPlayerName
    }
  }

  enum ViewAction {
    case letsPlayButtonTapped
    case logoutButtonTapped
    case oPlayerNameChanged(String)
    case xPlayerNameChanged(String)
  }

  public init(store: StoreOf<NewGame>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(self.store.scope(state: ViewState.init, action: NewGame.Action.init)) {
      viewStore in
      Form {
        Section {
          TextField(
            "Blob Sr.",
            text: viewStore.binding(get: \.xPlayerName, send: ViewAction.xPlayerNameChanged)
          )
          .autocapitalization(.words)
          .disableAutocorrection(true)
          .textContentType(.name)
        } header: {
          Text("X Player Name")
        }

        Section {
          TextField(
            "Blob Jr.",
            text: viewStore.binding(get: \.oPlayerName, send: ViewAction.oPlayerNameChanged)
          )
          .autocapitalization(.words)
          .disableAutocorrection(true)
          .textContentType(.name)
        } header: {
          Text("O Player Name")
        }

        Button("Let's play!") {
          viewStore.send(.letsPlayButtonTapped)
        }
        .disabled(viewStore.isLetsPlayButtonDisabled)
        .navigationTitle("New Game")
        .navigationBarItems(trailing: Button("Logout") { viewStore.send(.logoutButtonTapped) })
        .navigationDestination(
          store: self.store.scope(state: \.$game, action: NewGame.Action.game),
          destination: GameView.init(store:)
        )
      }
    }
  }
}

extension NewGame.Action {
  init(action: NewGameView.ViewAction) {
    switch action {
    case .letsPlayButtonTapped:
      self = .game(.present)
    case .logoutButtonTapped:
      self = .logoutButtonTapped
    case let .oPlayerNameChanged(name):
      self = .oPlayerNameChanged(name)
    case let .xPlayerNameChanged(name):
      self = .xPlayerNameChanged(name)
    }
  }
}

struct NewGame_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      NewGameView(
        store: Store(
          initialState: NewGame.State(),
          reducer: NewGame()
        )
      )
    }
  }
}
