#include <metal_stdlib>
#include <metal_integer>
#include <metal_math>

using namespace metal;

float linearTosRGB(float value) {
    float v = clamp(value, 0.0, 1.0);

    if (v <= 0.0031308) {
        return v * 12.92;
    } else {
        return 1.055 * pow(v, 1 / 2.4) - 0.055;
    }
}

[[ stitchable ]]
half4 simpleHash(float2 position,
                 half4 color,
                 float4 box,
                 float punch,
                 device const float *colors,
                 int count,
                 float floatWidth) {
    // Normalised pixel coords from 0 to 1
    vector_float2 uv = position/box.zw;

    uint width = uint(round(floatWidth));
    uint height = count / (3 * width);

    half4 out = half4(0);

    for (uint j = 0; j < height; j++) {
        for (uint i = 0; i < width; i++) {
            uint index = 3 * (i + width * j);
            float r = colors[index];
            float g = colors[index + 1];
            float b = colors[index + 2];
            half4 color = half4(r, g, b, 1);
            if (i == 0 && j == 0) {
                out += color;
            } else {
                float basis = cos(M_PI_F * float(i) * uv.x) * cos(M_PI_F * float(j) * uv.y);
                out += punch * basis * color;
            }
        }
    }

    return half4(linearTosRGB(out.r), linearTosRGB(out.g), linearTosRGB(out.b), 1);
}
