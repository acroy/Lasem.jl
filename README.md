# Lasem.jl

Lasem.jl is a Julia package that interfaces to the [Lasem library](https://wiki.gnome.org/Projects/Lasem),
which provides rendering of SVG and MathML using Pango/Cairo as backends. Rendering
of (La)TeX formulas is supported via [itex2mml](http://pear.math.pitt.edu/mathzilla/itex2mml.html).

## Installation

The Lasem library has to be installed manually. It can be obtained from [git.gnome.org](https://git.gnome.org/browse/lasem/)
or [github](https://github.com/GNOME/lasem). Building the library requires
`gobject, glib, gio, gdk-pixbuf, gdk, cairo, pangocairo, libxml, bison, flex`.
Additionally, the fonts `cmr10, cmmi10, cmex10 and cmsy10` should be available,
i.e. known to `fontconfig`.

Lasem.jl can then be installed via
```julia
Pkg.clone("git://github.com/acroy/Lasem.jl.git")
```

## Example: viewing SVGs, MathML and iTeX

As a simple application of Lasem, the examples directory contains
viewers of SVGs, files with MathML and iTeX expressions: `view_svg`
takes a filename as input, while `view_tex` accepts a `LaTeXString`. Both
require `Tk.jl` to be installed and will open a window showing the
rendering result. Resizing or other interactions are currently not supported.

## TeX labels in Winston

A more experimental application is rendering of LaTeX labels in [Winston](https://github.com/nolta/Winston.jl).
In the directory `winston` there are two variants: `winston-itex.jl` and
`winston-latex.jl`. Both replace the Winston text-rendering functions; the
first one uses `itex2mml`, while the latter uses `pdflatex` and [pdf2svg](http://www.cityinthesky.co.uk/opensource/pdf2svg/)
to render LaTeXStrings. This functionality is far from complete and any comments
or PRs are very welcome.
