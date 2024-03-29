import Defaults
import KeyboardShortcuts
import LaunchAtLogin
import Settings
import SwiftUI

struct GeneralView: View {
  @EnvironmentObject var appState: AppState

  var body: some View {
    VStack {
      Image("Cficon")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding([.bottom], 10)

      Grid(
        alignment: .leading,
        horizontalSpacing: 20.0,
        verticalSpacing: 15.0
      ) {
        GridRow {
          Text("Bật / Tắt gõ TV")
          Toggle("", isOn: $appState.enabled)
            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }

        GridRow {
          Text("Mở lúc bật Mac")
          LaunchAtLogin.Toggle("").toggleStyle(SwitchToggleStyle(tint: .accentColor))
        }
        GridRow {
          Text("Kiểu Gõ").frame(alignment: .leading)
          Picker("", selection: $appState.typingMethod) {
            ForEach(TypingMethods.allCases, id: \.self) { method in
              Text(method.rawValue)
            }
          }.pickerStyle(.segmented)
        }
        GridRow {
          Text("Phím tắt")
          KeyboardShortcuts.Recorder("", name: .toggleInputMode)
        }
        //          GridRow {
        //            Text("OpenAI Token \(Defaults[.token])")
        //            SecureField("Token", text: $token)
        //          }
      }

      Text(
        "Không có tính năng gì ngoài gõ Tiếng Việt !\n Developed by [KhanhIceTea](https://khanhicetea.com)."
      )
      .multilineTextAlignment(.center)
      .italic()
      .padding([.vertical], 10)

    }
    .frame(width: 270, height: 350)
    .padding(10)
  }
}

struct GeneralView_Previews: PreviewProvider {
  static var previews: some View {
    GeneralView()
      .environmentObject(AppState())
      .previewLayout(PreviewLayout.sizeThatFits)
      .padding()
      .previewDisplayName("GeneralView preview")
  }
}
