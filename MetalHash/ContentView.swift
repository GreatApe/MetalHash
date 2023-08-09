import SwiftUI

struct ContentView: View {
    var body: some View {
        if let hash = BlurHash(cubanLinx) {
            BlurHashView(hash: hash)
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

let cubanLinx = "ULI:%ZyD=xE3}ZEknhIVrDs:9]oLwitQE3xt"

#Preview {
    ContentView()
}
