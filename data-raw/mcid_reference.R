# Builds data/mcid_reference.rda from inst/extdata/mcid_reference.csv
mcid_reference <- read.csv("inst/extdata/mcid_reference.csv", stringsAsFactors = FALSE)
mcid_reference$value_num <- as.numeric(sub("^([0-9.]+).*", "\\1", mcid_reference$value))
mcid_reference <- mcid_reference[, c(1:7, ncol(mcid_reference), 8:(ncol(mcid_reference) - 1))]
dir.create("data", showWarnings = FALSE)
save(mcid_reference, file = "data/mcid_reference.rda", compress = "xz")
