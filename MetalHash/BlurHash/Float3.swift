import simd

typealias Float3 = SIMD3<Float>

extension Float3 {
    var array: [Float] {
        [x, y, z]
    }
}

// For interpolating between blurhashes:

extension [Float3] {
    static func *(lhs: Float, rhs: Self) -> Self {
        rhs.map { lhs * $0 }
    }

    static func +(lhs: Self, rhs: Self) -> Self {
        zip(lhs, rhs).map(+)
    }

    static func -(lhs: Self, rhs: Self) -> Self {
        zip(lhs, rhs).map(-)
    }
}

extension Float {
    func clamped(from lower: Float = 0, to upper: Float = 1) -> Float {
        max(lower, min(self, upper))
    }
}
