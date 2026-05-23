import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.golf")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("SD Golf Scorecard")
                .font(.largeTitle)
                .bold()
            Text("Hello, World!")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
