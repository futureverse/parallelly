# rivnet

<details>

* Version: 0.6.0
* GitHub: https://github.com/lucarraro/rivnet
* Source code: https://github.com/cran/rivnet
* Date/Publication: 2025-02-12 13:20:02 UTC
* Number of recursive dependencies: 134

Run `revdepcheck::revdep_details(, "rivnet")` for more info

</details>

## In both

*   checking whether package ‘rivnet’ can be installed ... ERROR
    ```
    Installation failed.
    See ‘/scratch/henrik/revdep/parallelly/checks/rivnet/new/rivnet.Rcheck/00install.out’ for details.
    ```

## Installation

### Devel

```
* installing *source* package ‘rivnet’ ...
** package ‘rivnet’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘g++ (GCC) 13.3.1 20240611 (Red Hat 13.3.1-2)’
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c RcppExports.cpp -o RcppExports.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c init_perm_rev.cpp -o init_perm_rev.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c path_vel.cpp -o path_vel.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c riverweight_src.cpp -o riverweight_src.o
g++ -std=gnu++17 -shared -L/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/lib -L/usr/local/lib64 -o rivnet.so RcppExports.o init_perm_rev.o path_vel.o riverweight_src.o -L/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/lib -lR
...
** R
** data
** inst
** byte-compile and prepare package for lazy loading
Error in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]) : 
  there is no package called ‘adespatial’
Calls: <Anonymous> ... loadNamespace -> withRestarts -> withOneRestart -> doWithOneRestart
Execution halted
ERROR: lazy loading failed for package ‘rivnet’
* removing ‘/scratch/henrik/revdep/parallelly/checks/rivnet/new/rivnet.Rcheck/rivnet’


```
### CRAN

```
* installing *source* package ‘rivnet’ ...
** package ‘rivnet’ successfully unpacked and MD5 sums checked
** using staged installation
** libs
using C++ compiler: ‘g++ (GCC) 13.3.1 20240611 (Red Hat 13.3.1-2)’
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c RcppExports.cpp -o RcppExports.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c init_perm_rev.cpp -o init_perm_rev.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c path_vel.cpp -o path_vel.o
g++ -std=gnu++17 -I"/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/include" -DNDEBUG  -I'/c4/home/henrik/futureverse/parallelly/revdep/library/rivnet/Rcpp/include' -I/usr/local/include    -fpic  -g -O2   -c riverweight_src.cpp -o riverweight_src.o
g++ -std=gnu++17 -shared -L/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/lib -L/usr/local/lib64 -o rivnet.so RcppExports.o init_perm_rev.o path_vel.o riverweight_src.o -L/software/c4/cbi/software/_rocky8/R-4.4.3-gcc13/lib64/R/lib -lR
...
** R
** data
** inst
** byte-compile and prepare package for lazy loading
Error in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]) : 
  there is no package called ‘adespatial’
Calls: <Anonymous> ... loadNamespace -> withRestarts -> withOneRestart -> doWithOneRestart
Execution halted
ERROR: lazy loading failed for package ‘rivnet’
* removing ‘/scratch/henrik/revdep/parallelly/checks/rivnet/old/rivnet.Rcheck/rivnet’


```
