import SwiftUI

struct SettingsView: View {
    @State private var launchAtLogin: Bool = LaunchAtLoginManager.shared.isEnabled

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .fontWeight(.heavy)
                .foregroundColor(.blue)

            Form {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        LaunchAtLoginManager.shared.setEnabled(newValue)
                    }
            }
            .formStyle(.grouped)

            Spacer()
        }
        .padding(20)
        .frame(width: 400, height: 200)
        .onAppear {
            // Refresh the value when view appears
            launchAtLogin = LaunchAtLoginManager.shared.isEnabled
        }
    }
}
