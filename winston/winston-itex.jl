#######
## Winston + Lasem to display LaTeX labels
#######
using Lasem

using Winston
using LaTeXStrings

Winston.textdraw(self::Winston.CairoRenderer, x::Real, y::Real, str::ByteString; kwargs...) =
    Winston.textdraw(self::Winston.CairoRenderer, x::Real, y::Real, latexstring(str); kwargs...)

Winston.textwidth(self::Winston.CairoRenderer, str::ByteString) =
    Winston.textwidth(self::Winston.CairoRenderer, latexstring(str))

Winston.textheight(self::Winston.CairoRenderer, str::ByteString) =
    Winston.textheight(self::Winston.CairoRenderer, latexstring(str))


function Winston.textdraw(self::Winston.CairoRenderer, x::Real, y::Real, str::LaTeXString;
    halign::String = "left", valign::String = "bottom", angle::Real = 0, markup::Bool=false)
# original Winston code
#    return Cairo.text(self.ctx, x, y, set_latex(self.ctx, str, get(self,:fontsize)); markup=true, kwargs...)

    println(str)
    println("align: $halign, $valign")

    # parse latex string
    doc = Lasem.lsm_mathml_document_new_from_itex(bytestring(str))
    doc != C_NULL || error("Processing of $str failed.")

    view = Lasem.lsm_dom_document_create_view(doc)
    view != C_NULL || error("Creating lasem view failed.")

#    Lasem.lsm_dom_view_set_resolution(view, 96.0)
    w, h = Lasem.lsm_dom_view_get_size(view)
    println("view size: $w, $h")
    wv = iceil(w)
    hv = iceil(h)

#    wv, hv = Lasem.lsm_dom_view_get_size_pixels(view)

    # Cairo context
    ctx = self.ctx

    # create Cairo surface and render image into it
    surface = surface_create_similar(ctx.surface, wv, hv)
    Lasem.lsm_dom_view_render(view, CairoContext(surface))
    println("ctx size: $(ctx.surface.width), $(ctx.surface.height)")

    save(ctx)

    # alignment offset
    dxrel = -Cairo.align2offset(halign)
    dyrel = -Cairo.align2offset(valign)

    # create pattern from surface and draw it
    pat = CairoPattern(surface)
    translate(ctx, x, y + hv)

#    set_source_rgba(ctx, 1, 0.1, 0.1, 0.6)
#    arc(ctx, 0., 0., 2.0, 0, 2*pi)
#    fill(ctx)

    rotate(ctx, angle*pi/180.)

#    rectangle(ctx, 0., 0., wv, hv)
#    stroke(ctx)

    translate(ctx, dxrel*wv, -dyrel*hv )
    ctm = get_matrix(ctx)

#    rectangle(ctx, 0., 0., abs(wv), hv)
#    stroke(ctx)

    println("cm: $ctm")
    println("sctx size: $(wv), $(hv)")
    println("pos: $(x + dxrel*wv), $(y -dyrel*hv)")
    println("pos: $(x + 0*dxrel*wv), $(y -0*dyrel*hv)")

    set_source(ctx, pat)
    set_matrix(pat, CairoMatrix(1., 0., 0., -1., 0., -hv))

    paint(ctx)
    restore(ctx)

    Lasem.destroy(view)
    Lasem.destroy(doc)

    ext = Float64[wv,hv]
    #ext = device_to_user_distance!(sctx, ext)
    ext = inv([ctm.xx ctm.xy; ctm.yx ctm.yy])*ext
    w = (ext[1])
    h = abs(ext[2])

    w, h = Base.Graphics.device_to_user(ctx, wv, hv)
    println("size: $w, $h\n")

    BoundingBox(x+dxrel*w, x+(dxrel+1)*w, y-dyrel*h, y+(1-dyrel)*h)
end

function Winston.textwidth(self::Winston.CairoRenderer, str::LaTeXString)
# original Winston code
#    layout_text(self, str)
#    extents = get_layout_size(self.ctx)
#    extents[1]
#
    doc = Lasem.lsm_mathml_document_new_from_itex(bytestring(str))
    doc != C_NULL || error("Processing of $str failed.")

    view = Lasem.lsm_dom_document_create_view(doc)
    view != C_NULL || error("Creating lasem view failed.")

#    Lasem.lsm_dom_view_set_resolution(view, 96.0)
#    w,h = Lasem.lsm_dom_view_get_size_pixels(view)
    w, h = Lasem.lsm_dom_view_get_size(view)

    Lasem.destroy(view)
    Lasem.destroy(doc)

    return w
end

function Winston.textheight(self::Winston.CairoRenderer, str::LaTeXString)
# original Winston code
#    get(self.state, :fontsize) ## XXX: kludge?
#
    doc = Lasem.lsm_mathml_document_new_from_itex(bytestring(str))
    doc != C_NULL || error("Processing of $str failed.")

    view = Lasem.lsm_dom_document_create_view(doc)
    view != C_NULL || error("Creating lasem view failed.")

#    Lasem.lsm_dom_view_set_resolution(view, 96.0)
#    w,h = Lasem.lsm_dom_view_get_size_pixels(view)
    w, h = Lasem.lsm_dom_view_get_size(view)

    Lasem.destroy(view)
    Lasem.destroy(doc)

    return h
end
