import Foundation

struct BlurHash: Hashable {
    let pixels: [Float3]
    let width: Int
}

extension BlurHash {
    var height: Int {
        pixels.count / width
    }

    var colors: [Float] {
        pixels.flatMap(\.array)
    }

    init?(_ hash: String, punch: Float = 1) {
        guard hash.count >= 6 else { return nil }

        let sizeFlag = String(hash[0]).decode83()
        let numY = (sizeFlag / 9) + 1
        let numX = (sizeFlag % 9) + 1

        let quantisedMaximumValue = String(hash[1]).decode83()
        let maximumValue = Float(quantisedMaximumValue + 1) / 166

        guard hash.count == 4 + 2 * numX * numY else { return nil }

        let colours: [Float3] = (0 ..< numX * numY).map { i in
            if i == 0 {
                let value = String(hash[2 ..< 6]).decode83()
                return decodeDC(value)
            } else {
                let value = String(hash[4 + i * 2 ..< 4 + i * 2 + 2]).decode83()
                return decodeAC(value, maximumValue: maximumValue * punch)
            }
        }

        self.init(pixels: colours, width: numX)
    }

}

// MARK: Helper functions

private func decodeDC(_ value: Int) -> Float3 {
    let intR = value >> 16
    let intG = (value >> 8) & 255
    let intB = value & 255
    return .init(sRGBToLinear(intR), sRGBToLinear(intG), sRGBToLinear(intB))
}

private func decodeAC(_ value: Int, maximumValue: Float) -> Float3 {
    let quantR = value / (19 * 19)
    let quantG = (value / 19) % 19
    let quantB = value % 19

    return .init(
        signPow((Float(quantR) - 9) / 9, 2) * maximumValue,
        signPow((Float(quantG) - 9) / 9, 2) * maximumValue,
        signPow((Float(quantB) - 9) / 9, 2) * maximumValue
    )
}

private func signPow(_ value: Float, _ exp: Float) -> Float {
    return copysign(pow(abs(value), exp), value)
}

private func sRGBToLinear<T: BinaryInteger>(_ value: T) -> Float {
    let v = Float(Int64(value)) / 255
    if v <= 0.04045 {
        return v / 12.92
    } else {
        return pow((v + 0.055) / 1.055, 2.4)
    }
}

private let encodeCharacters: [String] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#$%*+,-.:;=?@[]^_{|}~".map(String.init)

private let decodeCharacters: [String: Int] = {
    var dict: [String: Int] = [:]
    for (index, character) in encodeCharacters.enumerated() {
        dict[character] = index
    }
    return dict
}()

// MARK: Helper extensions

extension String {
    func decode83() -> Int {
        var value: Int = 0
        for character in self {
            if let digit = decodeCharacters[String(character)] {
                value = value * 83 + digit
            }
        }
        return value
    }
}

private extension String {
    subscript(offset: Int) -> Character {
        return self[index(startIndex, offsetBy: offset)]
    }

    subscript(bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start...end]
    }

    subscript(bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start..<end]
    }
}
