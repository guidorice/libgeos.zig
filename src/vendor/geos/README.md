# vendor/geos notes

This directory contains GEOS C API headers, which are an artifact of running `cmake` in `src/geos`.

Remember: these headers must be updated each time the git submodule for `src/geos`
is updated to a new release tag.

TODO: add vendor.sh script to make convenient running of cmake and copying headers into here. Basically what the steps are:

* fetch and checkout latest libgeos release tag.
* run cmake in build/.
* copy 2 geos c api headers into vendor/.
* git commit headers and commit geos submodule.

```shell
cd geos/
git switch main
git pull
git tag -l -n1
git checkout 3.10.2
rm -rf build/
mkdir build/
cd build/
cmake \
    -DCMAKE_C_COMPILER=zig-cc.sh \
    -DCMAKE_CXX_COMPILER=zig-cxx.sh \
    -DCMAKE_BUILD_TYPE=Release \
    ..
cp ./capi/geos_c.h ../../vendor/geos/build/capi/geos_c.h
cp ./include/geos/version.h ../../vendor/geos/build/include/geos/version.h 
cd ..
# commit changed files to git, commit git submodule for geos.
```

### zig-cxx.sh

```bash
#!/usr/bin/env bash
exec zig c++ "$@"
```

### zig-cc.sh

```bash
#!/usr/bin/env bash
exec zig cc "$@"
```