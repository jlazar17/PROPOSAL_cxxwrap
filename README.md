# PROPOSAL_cxxwrap

CxxWrap bindings exposing the [PROPOSAL](https://github.com/tudo-astroparticlephysics/PROPOSAL) particle-propagation library to Julia.

## Building

Prerequisites: CMake, a C++17 compiler, and the PROPOSAL and JlCxx libraries.

```bash
# Get the JlCxx prefix from Julia
JLCXX_PREFIX=$(julia -e 'using CxxWrap; print(CxxWrap.prefix_path())')

cmake -S . -B build \
  -DCMAKE_PREFIX_PATH="/path/to/PROPOSAL/install;$JLCXX_PREFIX" \
  -DCMAKE_INSTALL_PREFIX=install \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build --parallel
cmake --install build
```

## Testing

The test suite loads the compiled wrapper into Julia and exercises the type registrations and basic function calls.

### Using the JLL (released binary)

```bash
julia --project=test -e 'using Pkg; Pkg.instantiate()'
julia --project=test test/runtests.jl
```

### Using a local build

Point `LIBPROPOSAL_CXXWRAP_PATH` at your compiled library and make sure the PROPOSAL shared library is on the loader path:

```bash
export LIBPROPOSAL_CXXWRAP_PATH=$PWD/install/lib/libPROPOSAL_cxxwrap.so  # or .dylib on macOS
export LD_LIBRARY_PATH=/path/to/PROPOSAL/install/lib:$LD_LIBRARY_PATH     # DYLD_LIBRARY_PATH on macOS

julia --project=test -e 'using Pkg; Pkg.instantiate()'
julia --project=test test/runtests.jl
```

## CI

Push to `main` or open a pull request to trigger the GitHub Actions workflow (`.github/workflows/test.yml`). It builds PROPOSAL and the wrapper from source on Ubuntu, then runs the Julia tests.

## License

LGPL-3.0 — see [LICENSE.md](LICENSE.md).
