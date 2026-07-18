# OPEN-R SDK and R-CODE Support

## 1. Introduction

OPEN-R is the lowest-level public environment available for AIBO development.
You will not get much closer to the hardware. It expects a Unix-like workflow,
depends on GCC, and assumes some familiarity with C++ programming. In practice,
that usually means running Linux or using Cygwin on Windows.

OPEN-R runs on top of Sony's Aperios operating system, which is message
oriented and cooperatively multitasked. Code is organized into objects that
communicate by sending messages to one another. In most cases, an object
receives a message, processes it, and returns immediately. If it does not
return quickly, AIBO can become unresponsive.

For example, OPEN-R may periodically send a message containing the latest
camera image. Your code can process that image, perhaps looking for a ball, and
then return. Later, OPEN-R may send another message requesting a servo update,
allowing you to move the head or body before returning again.

## 2. Documentation and Sample Code

Before going too far, it is worth looking through the documentation and samples
to decide whether OPEN-R is the right level for what you want to do.

- Documentation: [OPEN_R_SDK-docE-1.1.5-r1.tar.gz](./OPEN_R_SDK-docE-1.1.5-r1.tar.gz)
  (about 2.4 MB)
- Samples: [OPEN_R_SDK-sample-1.1.5-r2.tar.gz](./OPEN_R_SDK-sample-1.1.5-r2.tar.gz)
  (about 3.8 MB)

If you are just starting out with AIBO programming, AiboPet's YART may be a
friendlier place to begin.

## 3. OPEN-R on Windows

On Windows, the traditional route is to install Cygwin first and then install
the OPEN-R SDK inside that environment. The compilers are prebuilt, so setup is
usually easier than a full native toolchain build.

Historical references mentioned by the original notes:

- Cygwin install tutorial
- OPEN-R on Cygwin install tutorial

## 4. OPEN-R on Linux

On Linux, a full toolchain build was traditionally required. In this repository,
the bundled SDK already covers that need for normal use, but the original source
archives and helper scripts are preserved here if you want to study or recreate
that process.

Relevant files in this directory include:

- [OPEN_R_SDK-1.1.5-r5.tar.gz](./OPEN_R_SDK-1.1.5-r5.tar.gz)
- [build-aibo-toolchain-3.3.6-r1.sh](./build-aibo-toolchain-3.3.6-r1.sh)
- [build-aibo-toolchain-local.sh](./build-aibo-toolchain-local.sh)
- [gcc-3.3.6.tar.bz2](./gcc-3.3.6.tar.bz2)
- [binutils-2.15.tar.bz2](./binutils-2.15.tar.bz2)
- [newlib-1.15.0.tar.gz](./newlib-1.15.0.tar.gz)

For this repo, the practical Linux path is:

1. Use the bundled SDK if you only want to build the included samples.
2. Rebuild the toolchain only if you want to reproduce or refresh the local SDK.

The repo already includes a local bootstrap script for that rebuild flow:

- [deps/build-aibo-toolchain-local.sh](../deps/build-aibo-toolchain-local.sh)

That script is designed for this repository layout and expects the source
archives in `deps/`. It rebuilds the cross-toolchain and installs it under a
repo-local prefix rather than relying on a system-wide install.

Typical usage from the repo root is:

```sh
cd deps
./build-aibo-toolchain-local.sh
```

By default, it installs to:

```text
local/rebuilt_OPEN_R_SDK
```

The script can also be redirected to a different install location by setting
`PREFIX` before running it.

If your goal is simply to verify that the already-bundled SDK works, you do not
need to rebuild anything. From the repo root, use:

```sh
make doctor
make hello-world
```

Those targets check the existing toolchain and build a known sample using the
SDK already present in `local/OPEN_R_SDK/`.

## 5. Flash Update for Older ERS-210 Units

Some older ERS-210 units need an OPEN-R firmware update before newer OPEN-R
programs will run correctly. Without that update, the AIBO may freeze and even
ignore the pause button, forcing a manual battery removal.

Updater archive:

- [upgrade-OPEN-R-1.1.3-r2.zip](./upgrade-OPEN-R-1.1.3-r2.zip) (about 4.1 MB)

Follow the vendor instructions in the archive, especially `README_E.txt`.

## 6. R-CODE Plugin for OPEN-R

Sony also released an OPEN-R plugin related to the R-CODE toolchain and its
extension points.

- [R-CODE-plugin-r1.tar.gz](./R-CODE-plugin-r1.tar.gz) (about 7.7 MB)

## 7. OPEN-R BBS Archive

The original OPEN-R SDE BBS contains a variety of useful historical information
about OPEN-R development.

- [Old_SDE_BBS.zip](./Old_SDE_BBS.zip) (about 691 KB)
