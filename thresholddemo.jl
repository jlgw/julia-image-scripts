using FileIO, Images, WebIO, InteractNext
include("imagelayers.jl")

try 
    global port += 1
catch
    global port = 9000
end

img = load("Lenna.png")
grimg = Gray.(img)

tdefault = otsu_threshold(grimg)
bimg = (grimg .< tdefault)
presenter = Present_image(bimg, grimg)

update(presenter)

ks = 0:0.01:1
thresholds = Dict(zip(ks, (x->Node(:div)).(ks)))
@async (for i in keys(thresholds)
            thresholds[i] = gen_bin(presenter, presenter.img_gs .< i)
end)

layout = @manipulate for tv in slider(0.0:0.01:1.0, value=round(float64(tdefault.val), 2))
    @async update_bin!(presenter, thresholds[tv])
    Node(:div, presenter(), style=Dict(:bottom=>"-400px"))
end


webio_serve(page("/", req->layout), port)
