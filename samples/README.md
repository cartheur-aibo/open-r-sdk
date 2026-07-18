# Samples Directory

This directory contains the Sony sample material that ships alongside the
bundled OPEN-R SDK workspace.

## What Is Here

- `common/`
  Common OPEN-R sample programs shared across multiple AIBO generations.
- `ers200/`
  Buildable OPEN-R samples for the ERS-200 era models.
- `ers7/`
  Buildable OPEN-R samples for ERS-7.
- `ers100/`
  ERS-100 era R-CODE script samples. These are included here as preserved
  OPEN-R SDK v1-era material, but they are not OPEN-R C++ projects.
- `CHANGES_E.txt`, `CHANGES_J.txt`
  Original Sony change notes from the sample archive.

## Buildable Vs. Non-Buildable Content

The active build system in this repository is for OPEN-R SDK projects built
with the bundled `mipsel-linux` cross toolchain and Sony's OPEN-R utilities.

Today, that build flow covers:

- `samples/common`
- `samples/ers200`
- `samples/ers7`

The top-level [Makefile](../Makefile) exposes:

- `make common-samples`
- `make all-samples`

Inside this directory, [Makefile](./Makefile) drives the same three component
groups and does not include `ers100`.

## Why `ers100` Is Different

The files in `samples/ers100/` are `.R` programs written in the older
ERS-100/ERS-111 style command language sometimes described as R-CODE.

These files look like:

```text
SET:Power:1
POSE:AIBO:std_std:::1
MOVE:LEGS:WALK:SLOW:FORWARD:0
PLAY:SOUND:joy1_xxa:100:1
```

That format is distinct from the OPEN-R sample layout used elsewhere in this
repo, where each sample typically has:

- one or more C++ source files
- a sample-local `Makefile`
- generated OPEN-R build artifacts such as `.elf` and `.bin`
- an `MS/OPEN-R/...` tree for Memory Stick packaging

Because of that difference, the current repo can store and document the
`ers100` material as part of the older OPEN-R SDK v1-era sample set, but it
does not compile those `.R` files with `make`.

## Practical Meaning

If you run `make all-samples`, you are building the OPEN-R sample suites only.
That is expected and currently correct.

If we want ERS-100 support in this repo, the next step is not a C++ build
target. It would be one of these:

- document the ERS-100 execution workflow
- add a staging target that packages `.R` files into the right Memory Stick
  layout
- add preservation notes describing which hardware or firmware setup is needed

## Current Intent

This repository is primarily an OPEN-R SDK workspace for the ERS-200 and ERS-7
era, with the `ers100` directory acting as preserved source material for the
earlier R-CODE-based platform and its older OPEN-R SDK v1-style sample set.
