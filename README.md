# open-r-sdk

OPEN-R / Aperios SDK workspace for AIBO ERS-200 and ERS-7 era development.

This repo already contains:

- a bundled, rebuilt SDK in `local/OPEN_R_SDK`
  including the Sony `OPEN_R` / `RP_OPEN_R` payload and the working `mipsel-linux` cross-toolchain
- Sony sample projects in `samples/`
- bootstrap scripts in `deps/` for rebuilding the legacy toolchain locally

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

If you want to override the SDK location:

```sh
make hello-world OPENRSDK_ROOT=/path/to/OPEN_R_SDK
```

## Notes

- Most sample makefiles default to `OPENRSDK_ROOT=/usr/local/OPEN_R_SDK`, so the root `Makefile` passes the repo-local SDK path for you.
- Generated OPEN-R artifacts such as `.bin`, `.elf`, and `.snap.cc` are ignored in git.
- `deps/build-aibo-toolchain-local.sh` is the local bootstrap script if we want to refresh or reproduce `local/OPEN_R_SDK`.
