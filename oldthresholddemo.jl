using FileIO, Images, WebIO, InteractNext

try 
    global port += 1
catch
    global port = 9000
end

img = load("Lenna.png")
grimg = Gray.(img)

gengrimg = WebIO.render(grimg)
image1 = Node(:div, gengrimg, style=Dict("width"=>"100%", "height"=>"100%", "bottom"=>"0", "right"=>"0", "position"=>"absolute"))

tdefault = otsu_threshold(grimg)

global bimg = Gray{N0f8}.(grimg .> tdefault)
layout = @manipulate for threshold in slider(0.0:0.01:1.0, value=[0.0, tdefault])
    @async global bimg = Gray{N0f8}.(threshold[2] .> grimg .> threshold[1])
    @async global bimgred = RGBA{N0f8}.(bimg.==1.0, 0.0, 0.0, 0.5*(bimg.==1.0))
    @async global genbimg = WebIO.render(bimgred)
    @async global image2 = Node(:div, genbimg, style=Dict("position"=>"absolute", "bottom"=>"0", "right"=>"0", "width"=>"100%", "height"=>"100%"))
    Node(:div, image1, image2, style=Dict(:position=>"relative", :bottom=>"-100px", :display=>"inline"))
end

webio_serve(page("/", req->layout), port)
