# open-r-sdk

OPEN-R / Aperios SDK workspace for AIBO ERS-200 and ERS-7 era development.

This repo already contains:

- a bundled, rebuilt SDK in `local/OPEN_R_SDK`
  including the Sony `OPEN_R` / `RP_OPEN_R` payload and the working `mipsel-linux` cross-toolchain
- Sony sample projects in `samples/`
- archived source inputs and a bootstrap script in `deps/` for rebuilding the bundled toolchain locally

## Current status

This can function as an active SDK build repo. The bundled toolchain runs on this host, and at least the `HelloWorld` sample builds successfully from source.

## Quick start

Run a quick toolchain check:

```sh
make doctor
```

Build the smallest sample set from the repo root:

```sh
make hello-world
```

Build and package it into its sample Memory Stick tree:

```sh
make hello-world-install
```

That produces:

- `samples/common/HelloWorld/HelloWorld/helloWorld.bin`
- `samples/common/PowerMonitor/PowerMonitor/powerMonitor.bin`
- `samples/common/HelloWorld/MS/OPEN-R/MW/OBJS/HELLO.BIN`

## Useful targets

```sh
make common-samples
make all-samples
make clean
```

ERS-7 `WCONSOLE` staging targets are also available:

```sh
make ers7-wconsole-hello-world
make ers7-wconsole-tinyftpd
```

If you want to override the SDK location:

```sh
make hello-world OPENRSDK_ROOT=/path/to/OPEN_R_SDK
```

## Notes

- Most sample makefiles default to `OPENRSDK_ROOT=/usr/local/OPEN_R_SDK`, so the root `Makefile` passes the repo-local SDK path for you.
- The `ers7-wconsole-*` targets stage a complete ERS-7 Memory Stick tree under `build/` by copying the SDK's `WCONSOLE` base and overlaying sample objects and config files.
- `ERS7_WCONSOLE_VARIANT` defaults to `memprot`. `memprot` enables memory protection and is better for bug isolation; `nomemprot` disables memory protection and can be useful for simpler bring-up or performance-oriented checks. We do not need to switch variants unless we have a specific reason.
- Generated OPEN-R artifacts such as `.bin`, `.elf`, and `.snap.cc` are ignored in git.
- `deps/build-aibo-toolchain-local.sh` is the local bootstrap script if we want to refresh or reproduce `local/OPEN_R_SDK`.
