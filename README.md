# symlink-app

This scripts packs executables and dynamic libraries into a Mac OS application bundle.

How to use:

1.  Copy your files into the `/Contents/Resources` directory of your app.  Create
    nested directories if you like.  This script will process them correctly.

2.  Run `pwsh Symlink-App.ps1 /path/to/my.app`.  This script:

    1.  Finds all executables and copies them into `Contents/MacOS`.
    2.  Finds all `.dylib` files and copies them into `Contents/Frameworks`.
    3.  Leaves a dynamic link from each original file location in 
        `/Contents/Resources` to its new location.

`pwsh` is Powershell, and can be installed with `brew install powershell`.  I first
tried to implement this script in `zsh`, but my application has a space in its name,
and simple things like `${path:t:e}` failed to parse the file extension. 