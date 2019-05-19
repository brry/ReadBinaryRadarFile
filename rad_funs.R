readBinFile <- function(binfile)
{ # Strongly simplified from original code by Henning Rust, FU Berlin meteo department
openfile <- file(binfile,"rb") # will be read successively
# read ascii header:
meta <- rawToChar(readBin(openfile,what=raw(),n=267,endian="little"))
# read the remaining binary data set:
# 900x900 is the dimension extracted from the header in real life
dat <- readBin(openfile,what=raw(),n=900*900*2,endian="little")
# close the data stream:
close(openfile)
dim(dat) <- c(2,900*900)
return(dat)
}


bin2num_fortran <- function(dat,dims=c(900,900),NAval=NA,CLUTTERval=NA) 
{ # Originally by Henning Rust, FU Berlin meteo department
fNAval <- -32767L
fCLUTTERval <- -32766L
RADconvF <- .Fortran("RADconv", raw=dat, dims=as.integer(dims),
                     numeric=as.integer(array(0,dim=c(dims[1]*dims[2]))),
                     fNAval=fNAval, fCLUTTERval=fCLUTTERval)
out <- RADconvF$numeric
out[out==fNAval] <- NAval
out[out==fCLUTTERval] <- CLUTTERval
return(out) 
}


bin2num_r <- function(dat) 
{ # Berry Boessenkool, May 2019
bits <- matrix(rawToBits(dat), ncol=16, byrow=TRUE) # bits 1-12: data
b2n <- function(i) as.numeric(bits[,i])*2^(i-1)
val <- b2n(1)+b2n(2)+b2n(3)+b2n(4)+b2n(5)+b2n(6)+b2n(7)+b2n(8)+b2n(9)+b2n(10)+b2n(11)+b2n(12)
#                                       # bit 13: flag for interpolated
val[bits[,14]==1] <- NA                 # bit 14: flag for missing
val[bits[,15]==1] <- -val[bits[,15]==1] # bit 15: flag for negative
val[bits[,16]==1] <- NA                 # bit 16: flag for clutter
return(as.integer(val))
}


# A 50 times slower loop version:
# bin2num_r2 <- function(dat) apply(dat, MARGIN=2, FUN=function(x){
# bits <- rawToBits(x)
# val <- sum(as.numeric(bits[1:12])*2^(0:11))
# if(bits[15]==1) val <- -val
# if(any(bits[c(14,16)]==1)) val <- NA
# return(as.integer(val))
# })
