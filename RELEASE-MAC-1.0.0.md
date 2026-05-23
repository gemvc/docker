# GEMVC Mac Variant Release

## Release Name
GEMVC Mac Variant Release — 1.0.0

## Description
This release introduces dedicated Mac developer variants for Apache, Nginx, OpenSwoole, and STCMS.
These variants are designed for Mac hosts and Apple Silicon-friendly development workflows while remaining Linux container-compatible.

## Release Highlights
- New Mac variant packages:
  - `gemvc/apache-mac:1.0.0`
  - `gemvc/nginx-mac:1.0.0`
  - `gemvc/swoole-mac:1.0.0`
  - `gemvc/stcms-mac:1.0.0`
- Added clean folder structure for Mac variants:
  - `apache-mac/`
  - `nginx-mac/`
  - `swoole-mac/`
  - `stcms-mac/`
- Updated top-level documentation to expose Mac-ready images and new build guidance.

## Docker Hub Package Strategy
- Publish Mac variants as first stable Mac developer release `1.0.0`.
- Keep `latest` tags for convenience alongside versioned tags.

## Recommended Tags
- `gemvc/apache-mac:1.0.0`
- `gemvc/nginx-mac:1.0.0`
- `gemvc/swoole-mac:1.0.0`
- `gemvc/stcms-mac:1.0.0`
- `gemvc/apache-mac:latest`
- `gemvc/nginx-mac:latest`
- `gemvc/swoole-mac:latest`
- `gemvc/stcms-mac:latest`

## Notes
- The Mac variants are still Linux-based containers.
- They are intended for backend/API development on Mac hosts, especially Apple Silicon.
- The standard repo images remain unchanged; these are additional Mac-specific packages.

---

## Patch Update
### apache-mac 1.0.1

- Updated and republished `gemvc/apache-mac` as a patch release.
- Published tags:
  - `gemvc/apache-mac:1.0.1`
  - `gemvc/apache-mac:latest`
- `latest` now points to `1.0.1`.
