# Read binary DWD Radolan data
# Berry Boessenkool, May 2019, berry-b@gmx.de
# For incorporation into rdwd, see             https://github.com/brry/rdwd#rdwd

# Two main questions:

# should binary to numeric conversion be done in pure R (700 ms per file)
# or with a FORTRAN routine (55ms), which will make rdwd compilation-needed   ?

# Can the pure-R conversion be sped up?


# At dir() should be: rad_ex.R (this file), rad_file, rad_fortran.f90, rad_funs.R

source("rad_funs.R") # readBinFile, bin2num_fortran, bin2num_r

# compile fortran code to a shared library at getwd():
# Once only: Open Terminal and type:        R CMD SHLIB rad_fortran.f90
# load DLL into R:
dyn.load("rad_fortran.dll") # on UNIX, may need to be   dyn.load("RADconv.so")

# Example with the first of 24*31=744 files in
#ftp://opendata.dwd.de/climate_environment/CDC/grids_germany/daily/radolan/historical/bin/2017/SF201712.tar.gz

dat <- readBinFile("rad_file")

br <- bin2num_r(dat)       # 700 milliseconds
bf <- bin2num_fortran(dat) #  55 milliseconds (as per microbenchmark below) 
all(bf==br, na.rm=TRUE) # TRUE
raster::plot(raster::raster(matrix(br,ncol=900)))

mb <- microbenchmark::microbenchmark(bin2num_r(dat), bin2num_fortran(dat), times=30)
boxplot(mb)
ggplot2::autoplot(mb)
mb



# Profiling:
nr <- 100
system.time( rtb <- replicate(nr, rawToBits(dat),                   simplify=FALSE)[[1]]) # 3-5 secs
system.time(bits <- replicate(nr, matrix(rtb, ncol=16, byrow=TRUE), simplify=FALSE)[[1]]) # 5-6 secs
b2n <- function(i) as.numeric(bits[,i])*2^(i-1)
system.time(val <- replicate(nr, b2n(1)+b2n(2)+b2n(3)+b2n(4)+b2n(5)+
               b2n(6)+b2n(7)+b2n(8)+b2n(9)+b2n(10)+b2n(11)+b2n(12), simplify=FALSE)[[1]]) # 27 secs
system.time(replicate(nr, {val[bits[,14]==1] <- NA ; val[bits[,15]==1] <- -val[bits[,15]==1] ; 
                          val[bits[,16]==1] <- NA},                 simplify=FALSE))      # 10 secs
val[bits[,14]==1] <- NA ; val[bits[,15]==1] <- -val[bits[,15]==1] ; val[bits[,16]==1] <- NA
system.time(replicate(nr, as.integer(val)))                                               # 2 secs
