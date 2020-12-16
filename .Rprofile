# graphics:::par(
#        bg = "black",
#        col = "white",
#        col.axis = "white",
#        col.lab = "white",
#        col.main = "white",
#        col.sub = "white",
#        pin = list(20, 20))
png <- function(filename = "Rplot%03d.png", width = 1200, height = 1200,
                units = "px", pointsize = 12, bg = "white", res = NA, family = "sans",
                restoreConsole = TRUE, type = c("windows", "cairo", "cairo-png"),
                antialias = c("default", "none", "cleartype", "gray", "subpixel"),
                symbolfamily = "default") {
    if (!grDevices:::checkIntFormat(filename)) {
          stop("invalid 'filename'")
      }
    g <- grDevices:::.geometry(width, height, units, res)
    if (match.arg(type) == "cairo") {
        antialias <- match(match.arg(antialias), grDevices:::aa.cairo)
        invisible(.External(
            C_devCairo, filename, 2L, g$width,
            g$height, pointsize, bg, res, antialias, 100L, if (nzchar(family)) family else "sans",
            300, chooseSymbolFont(symbolfamily)
        ))
    }
    else if (match.arg(type) == "cairo-png") {
        antialias <- match(match.arg(antialias), grDevices:::aa.cairo)
        invisible(.External(
            C_devCairo, filename, 5L, g$width,
            g$height, pointsize, bg, res, antialias, 100L, if (nzchar(family)) family else "sans",
            300, chooseSymbolFont(symbolfamily)
        ))
    }
    else {
        new <- if (!missing(antialias)) {
            list(bitmap.aa.win = match.arg(antialias, aa.win))
        }
        else {
            list()
        }
        antialias <- check.options(
            new = new, envir = grDevices:::.WindowsEnv,
            name.opt = ".Windows.Options", reset = FALSE, assign.opt = FALSE
        )$bitmap.aa.win
        invisible(.External(
            grDevices:::C_devga, paste0("png:", filename),
            g$width, g$height, pointsize, FALSE, 1L, NA_real_,
            NA_real_, bg, 1, as.integer(res), NA_integer_, FALSE,
            grDevices:::.PSenv, NA, restoreConsole, "", FALSE, TRUE, family,
            match(antialias, grDevices:::aa.win)
        ))
    }
}

setHook(
    packageEvent("grDevices", "onLoad"),
    function(...) {
        grDevices::windows.options(
            width = 15, height = 15,
            xpos = 0, pointsize = 12,
            bitmap.aa.win = "cleartype"
        )
    }
)


options(repos = structure(c(CRAN = "https://mirrors.dotsrc.org/cran/")))