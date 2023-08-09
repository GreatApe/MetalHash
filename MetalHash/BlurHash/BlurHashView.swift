import SwiftUI

struct BlurHashView: View {
    let hash: BlurHash

    var body: some View {
        Rectangle()
            .colorEffect(ShaderLibrary.simpleHash(
                .boundingRect,
                .float(1),
                .floatArray(hash.colors),
                .float(Float(hash.width))
            ))
            .compositingGroup()
    }
}
