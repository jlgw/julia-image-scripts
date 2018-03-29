using FileIO, InteractNext, Mux

try
    global port+=1
catch
    global port=9000
end
img = load("Lenna.png")

tb = textbox("Name")
ui = @manipulate for tb in textbox("Filename"),
    m in menu("Edit", ["Load", menu("Flips", ["Vertical", "Horizontal", "Both"])])
    WebIO.render(img)
end

on(observe(m)) do val
    if val=="Vertical"
        global img = ImageMagick.flip1(img)
    elseif val=="Horizontal"
        global img = ImageMagick.flip2(img)
    elseif val=="Both"
        global img = ImageMagick.flip12(img)
    elseif val=="Load"
        println("load")
        try
            global img = ImageMagick.load("$(observe(tb)[])")
        catch
            warn("Couldn't open $(observe(tb)[])")
        end
    end
end

webio_serve(page("/", req->Node(:div, ui)), port)
