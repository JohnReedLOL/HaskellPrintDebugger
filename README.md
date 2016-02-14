# HaskellPrintDebugger
Prints lines with IDE friendly stack traces in Haskell (now with IDE friendly fatal assertions).

____________________________________________________________________________________________________________________

Example:

> debugTraceIO "foobar"

foobar in thread "1" :

&nbsp;&nbsp;&nbsp;&nbsp;at Main.call(Main.hs:41)

See screenshot: http://i.imgur.com/KCXYHNk.png

-- New fatal assert feature: http://i.imgur.com/Ii62NJP.png


____________________________________________________________________________________________________________________

Dependencies:


- None (except for "split" package in .cabal). 

- Must specify "build-depends:   base, split, print-debugger" in .cabal file.

____________________________________________________________________________________________________________________

Instructions (without Cabal):

1. Simply Add the file "StackTraceDebug.hs" to your Haskell project.
2. Add "import Dugug.Print.StackTraceDebug" if you want to call the function.
3. Call "debugTraceIO" with any String argument.
4. When you are done, remove or comment out all calls to debugTraceIO.
5. Optionally, set value "debugMode" to "False" in "StackTraceDebug.hs" to mute all calls to "debugTraceIO" and disable all fatal assertions.

Instructions (without Cabal):

1. cabal update
2. cabal install split
3. cabal install print-debugger

^ Don't forget to include both "split" and "print-debugger" in the cabal file
____________________________________________________________________________________________________________________

Benefits:

- Does not require to be compiled with "-prof"
- Easier to locate your print statements (and assertions). Location of print statement (and assertions) can be highlighted in an IDE
- Easy to turn print statemments (and assertions) on/off without having to manually uncomment each one.
- CC0 (Free to use, share, or modify, even commercially)

____________________________________________________________________________________________________________________

Requirements:

- GHC 7.10.1 (or greater)
- "-XImplicitParams" compiler option
- "split" package or addition of ", split" to "build-depends" line in ".cabal" file

____________________________________________________________________________________________________________________
Configuration:

Sample ".cabal" file:

> name:              HaskellProject1

> version:           1.0

> Build-Type:        Simple

> cabal-version:     >= 1.2

>

> executable HaskellProject1

>   main-is:         Main.hs

>   hs-source-dirs:  src

>   build-depends:   base, split, print-debugger

Sample compilation: 

&nbsp;&nbsp;&nbsp;&nbsp;$> ghc StackTraceDebug.hs -Wall -Werror -XImplicitParams

____________________________________________________________________________________________________________________

Know bugs:

http://stackoverflow.com/questions/35354153/haskell-cannot-import-ghc-srcloc

^ Doesn't build correctly on Caball Ubuntu 14.04 with old (ubuntu LTS repo) version of GHC.

(but compiles fine on Windows with "ghc StackTraceDebug.hs -Wall -Werror -XImplicitParams")

To report or pinpoint bugs, email johnmichaelreedfas@gmail.com

____________________________________________________________________________________________________________________

More info:

http://hackage.haskell.org/package/print-debugger

https://www.reddit.com/r/haskell/comments/45jfk8/my_first_package_enhanced_poor_mans_debugging/

https://github.com/JohnReedLOL/HaskellPrintDebugger/edit/master/README.md



