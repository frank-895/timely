import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            
            // Horizontal row of two times
            HStack(spacing: 40) {
                // First placeholder time
                Text("12:34")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                
                // Second placeholder time
                Text("09:45")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
            }
            
            // Horizontal row of two locations under the times
            HStack(spacing: 40) {
                // First placeholder location
                Text("Location A")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Second placeholder location
                Text("Location B")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

/// Preview provider for SwiftUI previews
#Preview {
    ContentView()
}
