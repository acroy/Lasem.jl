module Lasem

    import Cairo: CairoContext  # for rendering

    const liblasem = "liblasem-0.6.5.dylib"
    const libgobject = "libgobject-2.0.0.dylib"

################################################################################
    # low-level wrapper for lasem functions

    immutable LsmBox
        x::Cdouble
        y::Cdouble
        width::Cdouble
        height::Cdouble
    end

    # general
    destroy(ptr::Ptr{Void}) = ccall((:g_object_unref, libgobject), Void, (Ptr{Void},), ptr)

    # document
    function lsm_dom_document_new_from_path(filename)
        ccall((:lsm_dom_document_new_from_path, liblasem), Ptr{Void}, (Ptr{Uint8}, Ptr{Void}), filename, C_NULL)
    end

    function lsm_dom_document_new_from_memory(buffer::Ptr{Uint8}, bufsize=length(buffer))
        ccall((:lsm_dom_document_new_from_memory, liblasem), Ptr{Void}, (Ptr{Uint8}, Uint32, Ptr{Void}), buffer, bufsize, C_NULL)
    end

    function lsm_mathml_document_new_from_itex(buffer, bufsize=length(buffer))
        ccall((:lsm_mathml_document_new_from_itex, liblasem), Ptr{Void}, (Ptr{Uint8}, Uint32, Ptr{Void}), buffer, bufsize, C_NULL)
    end

    function lsm_dom_document_create_view(doc::Ptr{Void})
        ccall((:lsm_dom_document_create_view, liblasem), Ptr{Void}, (Ptr{Void}, ), doc)
    end


    # view
    function lsm_dom_view_set_resolution(view::Ptr{Void}, ppi::Float64)
        ccall((:lsm_dom_view_set_resolution, liblasem), Void, (Ptr{Void}, Cdouble, ), view, ppi)
    end

    function lsm_dom_view_set_viewport_pixels(view::Ptr{Void}, viewport::LsmBox)
        ccall((:lsm_dom_view_set_viewport_pixels, liblasem), Void, (Ptr{Void}, Ptr{LsmBox} ), view, &viewport)
    end

    function lsm_dom_view_get_size_pixels(view::Ptr{Void})
        w_and_h = Uint32[0., 0.]
        ccall((:lsm_dom_view_get_size_pixels, liblasem), Void, (Ptr{Void}, Ptr{Uint32}, Ptr{Uint32}, Ptr{Void} ), view, pointer(w_and_h, 1), pointer(w_and_h, 2), C_NULL)

        return w_and_h[1], w_and_h[2]
    end

    function lsm_dom_view_get_size(view::Ptr{Void})
        w_and_h = Float64[0., 0.]
        ccall((:lsm_dom_view_get_size, liblasem), Void, (Ptr{Void}, Ptr{Float64}, Ptr{Float64}, Ptr{Void} ), view, pointer(w_and_h, 1), pointer(w_and_h, 2), C_NULL)

        return w_and_h[1], w_and_h[2]
    end

    function lsm_dom_view_render(view::Ptr{Void}, cairo::CairoContext, x::Float64=0., y::Float64=0.)
        ccall((:lsm_dom_view_render, liblasem), Void, (Ptr{Void}, Ptr{Void}, Cdouble, Cdouble ), view, cairo.ptr, x, y)
    end

################################################################################
    # TODO
    # high level interface
    type LsmDoc
        ptr::Ptr{Void}
    end

    type LsmView
        ptr::Ptr{Void}

        function LsmView(doc::LsmDoc)
            view = lsm_dom_document_create_view(doc.ptr)
            view != C_NULL || error("Creating lasem view failed.")

            new(view)
        end
    end

    function render(view::LsmView, ctx::CairoContext)
        lsm_dom_view_render(view.ptr, ctx)
        return nothing
    end

end # module
