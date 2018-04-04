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

layout = @manipulate for tv in slider(ks, value=[0.0, round(float64(tdefault.val), 2)])
    img_high = tv[1] .< presenter.img_gs
    img_low = presenter.img_gs .< tv[2]
    presenter.img_bin =  (img_high .& img_low)
    update_bin!(presenter)
    Node(:div, presenter(), style=Dict(:bottom=>"-400px"))
end


webio_serve(page("/", req->layout), port)
