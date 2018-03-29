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

thresholds = Dict(zip(0:0.01:1, Node(:div)))
for i in keys(thresholds)
    @async (thresholds[i] = gen_bin(presenter, presenter.img_gs .< i), println("$i done"))
end

layout = @manipulate for tv in slider(0.0:0.01:1.0)

    update_bin!(presenter)
    Node(:div, presenter(), style=Dict(:bottom=>"-200px"))
end

on(observe(tv)) do val
    println(time()%100)
end

webio_serve(page("/", req->layout), port)
