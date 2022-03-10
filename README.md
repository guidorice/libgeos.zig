# libgeos.zig

[Zig](https://ziglang.org) bindings for the [GEOS C library (libgeos)](https://libgeos.org/)

> GEOS (Geometry Engine, Open Source) is a C/C++ library for spatial computational geometry of the sort generally used by “geographic information systems” software. GEOS is a core dependency of PostGIS, QGIS, GDAL, and Shapely.

## GEOS version

`3.10.2-CAPI-1.16.0`

## Zig version

* `0.9.1`, `0.10.0-dev`

## Build

Requires only `zig`. Don't forget to clone/init the submodule!

```shell
git clone --recurse-submodules https://github.com/guidorice/libgeos.zig.git
cd libgeos.zig/
zig build
```

## Tests

```shell
zig build test
```

## Examples

```shell
$ zig build --help
$ zig build run-example1
Geometry A:         POLYGON((0 0, 10 0, 10 10, 0 10, 0 0))
Geometry B:         POLYGON((5 5, 15 5, 15 15, 5 15, 5 5))
Intersection(A, B): POLYGON ((10 10, 10 5, 5 5, 5 10, 10 10))
```

## Known Issues

* blocker: The libgeos library uses C++ `std::runtime_error`, which is not currently
captured by the Zig wrapper code. As a result, there is no way to recover from
some error conditions, for example, failing to parse some WKT formatted string. 
[see issue #9](https://github.com/guidorice/libgeos.zig/issues/9)

## Roadmap

- [x] Minimal build.zig. Builds libgeos entirely using Zig compiler and build system.
- [x] Create example exe using this package as a Zig library.
- [ ] Solution for `std:runtime_error` conditions (see known issues)
- [ ] Port (rest of) libgeos C examples to Zig  (from src/geos/examples)
- [ ] Port reentrant/threadsafe libgeos C examples to Zig.
- [ ] New Zig idiomatic wrapper for libgeos C API.
- [ ] New GeoJSON reader/writer which speaks libgeos types and full support for Feature properties. Reference: [GEOS GeoJSON support notes here.](https://libgeos.org/specifications/geojson/)
- [ ] New Zig projects which utilize these Geospatial or Geometric primitives.

## Notes

See also [vendor/geos/README](src/vendor/geos/README.md) for how libgeos is
updated within this repo.
