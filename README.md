
En route to enable [rdwd](https://github.com/brry/rdwd#rdwd)
to handle gridded Radar data (Radolan binary files).  
What is the best way for my package to convert binary to numeric?

Henning Rust (Meteo FU Berlin) kindly provided a Fortran routine for said conversion.  
I have no experience with outsourcing code in an R package and wonder if this brings disadvantages.  
Hence I have two main questions:

- should binary to numeric conversion be done in pure R (700 ms per file)  
or with a FORTRAN routine (55ms), which will make rdwd compilation-needed?

- Can the pure-R conversion (see [code](https://github.com/brry/ReadBinaryRadarFile/blob/master/rad_funs.R#L30)) be sped up?

See the example code at [rad_ex.R](https://github.com/brry/ReadBinaryRadarFile/blob/master/rad_ex.R)
if you want to run tests.


