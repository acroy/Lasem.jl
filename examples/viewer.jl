using Base.Graphics
using Cairo
using Tk

using Lasem
using LaTeXStrings


function view_svg(filename)
    # use lasem to open svg file
    doc = Lasem.lsm_dom_document_new_from_path(filename)
    doc != C_NULL || error("Opening and/or processing of file $filename failed.")

    view = Lasem.lsm_dom_document_create_view(doc)
    view != C_NULL || error("Creating lasem view failed.")

    Lasem.lsm_dom_view_set_resolution(view, 96.0)
    w,h = Lasem.lsm_dom_view_get_size_pixels(view)

    # create Cairo surface and render image into it
    surface = CairoARGBSurface(w, h)
    Lasem.lsm_dom_view_render(view, CairoContext(surface))

    # create Window to display image
    win = Toplevel("SVG", w, h)
    c = Canvas(win)
    pack(c, expand=true, fill="both")

    ctx = getgc(c)

    image(ctx, surface, 0, 0, int(w), int(h))

    reveal(c)
    Tk.update()

    Lasem.destroy(view)
    Lasem.destroy(doc)
end

function view_tex(expr::ASCIIString)
    const margin = 10

    # use lasem to render equation
    doc = Lasem.lsm_mathml_document_new_from_itex(expr)
    doc != C_NULL || error("Processing of $expr failed.")

    view = Lasem.lsm_dom_document_create_view(doc)
    view != C_NULL || error("Creating lasem view failed.")

    Lasem.lsm_dom_view_set_resolution(view, 96.0)
    w,h = Lasem.lsm_dom_view_get_size_pixels(view)

    # create Cairo surface and render image into it
    surface = CairoARGBSurface(w, h)
    Lasem.lsm_dom_view_render(view, CairoContext(surface))

    # create Window to display image
    win = Toplevel("iTeX", w+2*margin, h+2*margin)
    c = Canvas(win)
    pack(c, expand=true, fill="both")

    ctx = getgc(c)

    rectangle(ctx, margin, margin, int(w), int(h))
    set_source_rgb(ctx, 1, 0, 1)
    stroke(ctx)
    image(ctx, surface, margin, margin, int(w), int(h))

    reveal(c)
    Tk.update()

    Lasem.destroy(view)
    Lasem.destroy(doc)
end

view_tex(ls::LaTeXString) = view_tex(bytestring(ls))
