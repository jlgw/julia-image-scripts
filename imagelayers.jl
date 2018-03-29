using WebIO, Images
const color = "red"
const bin_opacity = 0.5

const bgstyle   = Dict(:width=>"100%", :height=>"100%", :bottom=>"0", :right=>"0", :position=>"absolute")
const topstyle  = Dict(:width=>"100%", :height=>"100%", :bottom=>"0", :right=>"0", :position=>"absolute")
const contstyle = Dict(:position=>"relative", :display=>"inline")

function bin_colormap(color, opacity)
    if color=="red"
        b -> (b ? (1.0, 0.0, 0.0, opacity) : (0.0, 0.0, 0.0, 0.0))
    elseif color=="blue"
        b -> (b ? (0.0, 1.0, 0.0, opacity) : (0.0, 0.0, 0.0, 0.0))
    elseif color=="green"
        b -> (b ? (0.0, 1.0, 1.0, opacity) : (0.0, 0.0, 0.0, 0.0))
    end
end

mutable struct Present_image
    img_bin
    img_gs
    node_bin::WebIO.Node
    node_gs::WebIO.Node
    prefs::Dict
    state::Dict
end

function Present_image(binimg, gsimg)
    prefs = Dict(:color=>"red",
                 :bin_opacity=>0.5,
                )
    state = Dict()
    Present_image(binimg, gsimg, Node(:div), Node(:div), prefs, state)
end

function updatebin(present_image::Present_image)
    present_image.node_bin = RGBA{N0f8}(bin_colormap(present_image.prefs[:color],
                                                     present_image.prefs[:bin_opacity],
                                                    ).(present_image.img_bin))
end

function updatebin(present_image::Present_image)
    colorized = (x-> RGBA{N0f8}(bin_colormap(present_image.prefs[:color],
                                             present_image.prefs[:bin_opacity],
                                            )(x)...)).(present_image.img_bin)
    present_image.node_bin = Node(:div, WebIO.render(colorized), style=topstyle)
end

function updategs(present_image::Present_image)
    present_image.node_gs = Node(:div, WebIO.render(present_image.img_gs), style=bgstyle)
end

function update(present_image::Present_image)
    updategs(present_image)
    updatebin(present_image)
end

function (present_image::Present_image)()
    Node(:div, present_image.node_gs, present_image.node_bin, style=contstyle)
end

