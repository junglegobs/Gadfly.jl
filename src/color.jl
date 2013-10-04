
# Various color scales.


# Weighted mean of some number of colors within the same space.
#
# Args:
#  cs: Colors.
#  ws: Weights of the same length as cs.
#
# Returns:
#   A weighted mean color of type T.
#
function weighted_color_mean{S <: Number}(
        cs::AbstractArray{LAB,1}, ws::AbstractArray{S,1})
    l = 0.0
    a = 0.0
    b = 0.0
    sumws = sum(ws)
    for (c, w) in zip(cs, ws)
        w /= sumws
        l += w * c.l
        a += w * c.a
        b += w * c.b
    end
    LAB(l, a, b)
end


# Discrete scales
# ---------------

# Generate colors in the LCHab (LCHuv, resp.) colorspace by using a fixed
# luminance and chroma, and varying the hue.
#
# Args:
#   l: luminance
#   c: chroma
#   h0: start hue
#   n: number of colors
#
function lab_rainbow(l, c, h0, n)
    ColorValue[LCHab(l, c, h0 + 360.0 * (i - 1) / n) for i in 1:n]
end

function luv_rainbow(l, c, h0, n)
    ColorValue[LCHuv(l, c, h0 + 360.0 * (i - 1) / n) for i in 1:n]
end

# Helpful for Experimenting
function plot_color_scale{T <: ColorValue}(colors::Vector{T})
    println(colors)
    canvas(UnitBox(length(colors), 1)) <<
            (compose([rectangle(i-1, 0, 1, 1) << fill(c)
                      for (i, c) in enumerate(colors)]...) << stroke(nothing))
end


# Continuous scales
# -----------------

# Generate a gradient between n >= 2, colors.

# Then functions return functions suitable for ContinuousColorScales.
function lab_gradient(cs::ColorValue...)
    if length(cs) < 2
        error("Two or more colors are needed for gradients")
    end

    cs_lab = [convert(LAB, c) for c in cs]
    n = length(cs_lab)
    function f(p::Float64)
        @assert 0.0 <= p <= 1.0
        i = 1 + min(n - 2, max(0, int(floor(p*(n-1)))))
        w = p*(n-1) + 1 - i
        weighted_color_mean([cs_lab[i], cs_lab[i+1]], [1.0 - w, w])
    end
    f
end

