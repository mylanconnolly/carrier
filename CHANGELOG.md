# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1] - 2025-04-02

### Added

- Improved documentation
- Added changelog

### Fixed

- Removed duplicated code

## [2.0.0] - 2025-04-02

### Added

- Complete revamp of logic; now uses Req instead of HTTPoison

### Changed

- Carrier is no longer a GenServer, and you do not need to add it to your
  application's supervision tree.
- Carrier now operates on maps rather than tuples. This allows us to return
  more detailed responses from Smarty, allowing us to take fuller advantage of
  the API.

## LEGACY VERSIONS

Changelog entries are not included for legacy versions, as they were originally
deployed ~10 years before a complete refactoring. Any version prior to 2.0 is
not supported or recommended.
