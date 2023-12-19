# Web Server POC in Zig

> Listens on for a single HTTP request receiving a file path, looks for the requested file, and serves it.

_Uses OS's socket API for network transfer._

## Usage

**Hardcoded to listen on 0.0.0.0:8080**
_assuming `zig` is installed_

1. Compile and run the program `zig build run`.
2. Send HTTP request with file path to URL `wget 0.0.0.0:8080/index.html`
