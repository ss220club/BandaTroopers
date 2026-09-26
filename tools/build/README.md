# /tg/station build script

This build script is the recommended way to compile the game, including not only the DM code but also the JavaScript and any other dependencies.

- VSCode:
  a) Press `Ctrl+Shift+B` to build.
  b) Press `F5` to build and run with debugger attached.
- Windows:
  a) Double-click `BUILD.cmd` in the repository root to build (will wait for a key press before it closes).
  b) Double-click `tools/build/build.bat` to build (will exit as soon as it finishes building).
- Linux:
  a) Run `tools/build/build` from the repository root.

The script will skip build steps whose inputs have not changed since the last run.
Parameterized DM checks (`--ci`, `-D`, `-W`, or `--dm-version`) always rebuild,
because their output is not compatible with an ordinary cached DMB. To force an
otherwise normal DM rebuild, run:

```
tools/build/build dm --force
```

CI verification requires the exact BYOND version selected by the CI environment
(normally the version pinned in `dependencies.sh`; alternate-version jobs set an
explicit override). Ordinary local builds warn on a version mismatch.

## Getting list of available targets

You can get a list of all targets that you can build by running the following command:

```
tools/build/build --help
```

## Dependencies

- On Windows, `build.bat` will automatically install a private (vendored) copy of Node.
- On Linux, install Node using your package manager or from <https://nodejs.org/en/download/>.
- On Linux, unless using tgs4 or later you will need to compile rust-g on the server and obtain a .so file, for instructions see https://github.com/tgstation/rust-g

## Why?

We used to include compiled versions of the tgui JavaScript code in the Git repository so that the project could be compiled using BYOND only. These pre-compiled files tended to have merge conflicts for no good reason. Using a build script lets us avoid this problem, while keeping builds convenient for people who are not modifying tgui.

This build script is based on [Juke Build](https://github.com/stylemistake/juke-build) - follow the link to read the documentation for the project and understand how it works and how to contribute.
