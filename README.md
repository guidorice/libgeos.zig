# GEOS

Zig bindings for the [GEOS C library](https://libgeos.org/).

> GEOS is a C/C++ library for spatial computational geometry of the sort generally used by “geographic information systems” software. GEOS is a core dependency of PostGIS, QGIS, GDAL, and Shapely.

## Build

```shell
git clone --recurse-submodules https://github.com/guidorice/geos.git
cd geos/
zig build
```

## Test

```shell
zig build test
```

## Examples

TODO

## Contribute

Pull requests or issues are welcome.

```shell
cmake -D CMAKE_C_COMPILER=zig-cc.sh -D CMAKE_CXX_COMPILER=zig-cxx.sh ..
make
```
