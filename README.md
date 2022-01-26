# libgeos.zig

[Zig](https://ziglang.org) bindings for the [GEOS C library (libgeos)](https://libgeos.org/).

> GEOS is a C/C++ library for spatial computational geometry of the sort generally used by “geographic information systems” software. GEOS is a core dependency of PostGIS, QGIS, GDAL, and Shapely.

## Build

Don't forget to clone/init the submodule!

```shell
git clone --recurse-submodules https://github.com/guidorice/libgeos.zig.git
cd libgeos.git/
zig build
```

## Tests

```shell
zig build test
```

## Examples

TODO

## Roadmap

- [x] Minimal build.zig. Builds libgeos entirely using Zig compiler and build system.
- [ ] Example of using this package as a Zig library.
- [ ] Port libgeos C tests to Zig.
- [ ] Port libgeos C examples to Zig.
- [ ] New Zig idiomatic wrapper for libgeos C API.
- [ ] New GeoJSON reader/writer which speaks libgeos types and full support for Feature properties. Reference: [GEOS GeoJSON support notes here.](https://libgeos.org/specifications/geojson/)
- [ ] New Zig projects which would use Geospatial or Geometric primitives.

## Contribute

Pull requests or issues are welcome!
