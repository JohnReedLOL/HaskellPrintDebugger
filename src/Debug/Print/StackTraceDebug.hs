{-# LANGUAGE ImplicitParams #-}
{- This file is in the public domain. Originally written by John-Michael Reed (who is not legally liable if it breaks) -}
module Debug.Print.StackTraceDebug where

{- Requires GHC version 7.10.1 (or greater) to compile -}
{- Suggested for use with IntelliJ or EclipseFP -}

import Control.Concurrent -- for myThreadID
import Debug.Trace -- for traceIO
import GHC.Stack
import GHC.SrcLoc -- this is for getting the fine name, line number, etc.
import System.Info -- this is for getting os
import Data.List -- isInfixOf, intercalate
import Data.List.Split -- used for splitting strings

--
-- | Set to "False" and recompile in order to disable print statements with stack traces.
--
debugMode :: Bool
debugMode = True

--
-- | Prints message with a one line stack trace (formatted like a Java Exception for IDE usability). Meant to be a substitute for Debug.Trace.traceIO
--
debugTraceIO :: (?loc :: CallStack) => String -> IO ()
debugTraceIO message = do
  callStacks <- return(getCallStack (?loc)) -- returns [(String, SrcLoc)]
  let callStack = Data.List.last(callStacks) -- returns (String, SrcLoc)
  let callOrigin =  snd callStack -- returns SrcLoc
  let pathToFileName =  srcLocModule callOrigin
  let fileName =  srcLocFile callOrigin
  let lineNumber =  show(srcLocStartLine callOrigin)
  noMonadThreadId <- myThreadId -- myThreadId returns IO(ThreadID)
  let threadName =  show(noMonadThreadId)
  let threadNameWords = splitOn  " " threadName -- break up thread name along spaces
  let threadNumberString =  Data.List.last threadNameWords -- this isn't working
  let fileNameSplit = if ((Data.List.isInfixOf "win" os) || (Data.List.isInfixOf "Win" os) || (Data.List.isInfixOf "mingw" os))
                        then splitOn ("\\") fileName
                        else splitOn ("/") fileName
  let fileNameSplitDropHead = if (length fileNameSplit > 1)
                                then tail fileNameSplit
                                else fileNameSplit
  let fileNameParsed = if ((Data.List.isInfixOf "win" os) || (Data.List.isInfixOf "Win" os) || (Data.List.isInfixOf "mingw" os))-- Data.List.Split.splitOn " " threadName)
                         then intercalate "\\" fileNameSplitDropHead
                         else intercalate "/" fileNameSplitDropHead
  let lineOne =  message ++ " in" ++ " thread" ++ " " ++ "\"" ++ threadNumberString ++ "\"" ++ " :"
  let lineTwo =  "    "  ++ "at " ++ pathToFileName ++ ".call" ++ "(" ++ fileNameParsed ++ ":" ++ lineNumber ++ ")"
  let toPrint = if ((Data.List.isInfixOf "win" os) || (Data.List.isInfixOf "Win" os) || (Data.List.isInfixOf "mingw" os))
                  then  lineOne ++ "\r\n" ++ lineTwo ++ "\r\n"
                  else  lineOne ++ "\n" ++ lineTwo ++ "\n" -- linesOneAndTwo = unlines [lineOne, lineTwo])
  if debugMode
     then traceIO toPrint
     else return()

--
-- | Shorthand for "debugTraceIO". Prints a message with a formatted stack trace.
--
prt :: (?loc :: CallStack) => String -> IO ()
prt = debugTraceIO

--
-- | This method tests the "debugTraceIO" function.
--
test :: IO()
test = do
  debugTraceIO "foobarbaz"
  debugTraceIO "lalalalaaaaa"
  prt "Shorthand for debugTraceIO"

{-

Sample output:

foobarbaz in thread "ThreadId 1" :
    at Main.call(Main.hs:78)

lalalalaaaaa in thread "ThreadId 1" :
    at Main.call(Main.hs:79)

Shorthand for debugTraceIO in thread "ThreadId 1" :
    at Main.call(Main.hs:80)
-}
