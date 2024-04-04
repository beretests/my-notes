Number of CPUs  = Threads per core * Cores per socket * Sockets

Cores = Cores per socket * Sockets

`lscpu` lists the individual CPU components

```
lscpu | grep -E '^Thread|^Core|^Socket|^CPU\('
```

`nproc` output is CPU count from `lscpu`