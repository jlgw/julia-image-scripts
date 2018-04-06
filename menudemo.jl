using FileIO, InteractNext, Mux

include("imagelayers.jl")

try
    global port+=1
catch
    global port=9000
end

img = Gray.(load("Lenna.png"))
bimg = img .== 2
presenter = Present_image(bimg, img)
update(presenter)

function dummyslider(x)
    s = slider(x)
    s.dom.props["style"] = Dict(:display => "none")
    s
end
    
m1 = menu("Edit", ["Load", menu("Flips", ["Vertical", "Horizontal", "Both"])])
m2 = menu("Ops", ["Invert", "Threshold"])

ks = 0:0.01:1
tdefault = otsu_threshold(img)
tvslider = slider(ks, value=[0.0, round(float64(tdefault.val), 2)])
tvbtn = button("Done")

on(observe(tvslider)) do val
    img_high = val[1] .< presenter.img_gs
    img_low = presenter.img_gs .< val[2]
    presenter.img_bin =  (img_high .& img_low)
    update_bin!(presenter)
    observe(dummy)[] = observe(dummy)[]
end

on(observe(tvbtn)) do val
    evaljs(m2, js""" (function () {
           var obj = document.getElementById("thresh");
           obj.style.display = "none";
           })()""")
end

t_cont = dom"div"(tvslider, tvbtn, attributes=Dict("id"=>"thresh"))

ui = @manipulate for dummy in dummyslider(0:10)
    t = time()
    #rr = WebIO.render(img)
    println("rendering time $(time()-t)")
    presenter()
end

on(observe(m1)) do val
    if val in ["Flips", ""]
        return
    elseif val=="Vertical"
        global img = img[end:-1:1, :]
    elseif val=="Horizontal"
        global img = img[:, end:-1:1]
    elseif val=="Both"
        global img = img[end:-1:1, end:-1:1]
    elseif val=="Load"
        println("load")
        try
            global img = load("$(observe(tb)[])")
        catch
            warn("Couldn't open $(observe(tb)[])")
        end
    end
    observe(dummy)[] = observe(dummy)[]
    observe(m1)[] = ""
end

on(observe(m2)) do val
    if val==""
        return
    elseif val=="Invert"
        global img = Gray{N0f8}.(1 - img)
    elseif val=="Threshold"
        evaljs(m2, js""" (function () {
               var obj = document.getElementById("thresh");
               obj.style.display = "";
               })()""")
    end
    observe(dummy)[] = observe(dummy)[]
    observe(m2)[] = ""
end

mbar = dom"md-menubar"(m1, m2)
utilities = dom"div"(t_cont)
webio_serve(page("/", req->Node(:div, mbar, utilities, Node(:div, ui))), port)
