{-# LANGUAGE ImplicitParams #-}
{- This file is free to use, distribute, and modify, even commercially. Originally written by John-Michael Reed (who is not legally liable) -}
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
import System.Exit -- for fatal assert


-- | Set to "False" and recompile in order to disable print statements with stack traces.
--
debugMode :: Bool
debugMode = True

-- | Prints message with a one line stack trace (formatted like a Java Exception for IDE usability). Meant to be a substitute for Debug.Trace.traceIO
--
debugTraceIO :: (?loc :: CallStack) => String -> IO ()
debugTraceIO message = do -- Warning: "callStacks <- return(getCallStack (?loc))" cannot be replaced with "let callStacks = getCallStack (?loc)" because doing so would mess up the call stack.
  callStacks <- return(getCallStack (?loc)) -- returns [(String, SrcLoc)]
  let callStack = Data.List.last callStacks -- returns (String, SrcLoc)
  let callOrigin =  snd callStack -- returns SrcLoc
  let pathToFileName =  srcLocModule callOrigin
  let fileName =  srcLocFile callOrigin
  let lineNumber =  show(srcLocStartLine callOrigin)
  noMonadThreadId <- myThreadId -- myThreadId returns IO(ThreadID)
  let threadName =  show noMonadThreadId
  let threadNameWords = splitOn  " " threadName -- break up thread name along spaces
  let threadNumberString =  Data.List.last threadNameWords -- this isn't working
  let fileNameSplit = if (("win" `isInfixOf` os) || ("Win" `isInfixOf` os) || "mingw" `isInfixOf` os)
                        then splitOn "\\" fileName
                        else splitOn "/" fileName
  let fileNameNoCruff = if (length fileNameSplit > 1)
                                then last (tail fileNameSplit)
                                else head fileNameSplit
  let lineOne =  message ++ " in" ++ " thread" ++ " " ++ "\"" ++ threadNumberString ++ "\"" ++ " :"
  let lineTwo =  "    "  ++ "at " ++ pathToFileName ++ ".call" ++ "(" ++ fileNameNoCruff ++ ":" ++ lineNumber ++ ")"
  let toPrint = if ((Data.List.isInfixOf "win" os) || (Data.List.isInfixOf "Win" os) || (Data.List.isInfixOf "mingw" os))
                  then  lineOne ++ "\r\n" ++ lineTwo ++ "\r\n"
                  else  lineOne ++ "\n" ++ lineTwo ++ "\n" -- linesOneAndTwo = unlines [lineOne, lineTwo])
  if debugMode
     then traceIO toPrint
     else return()

     {- Warning: Reduce duplication. The below code cannot be refactored out into a function because doing so would break the stack trace -}

-- | Kills the application and prints the message with a one line stack trace (formatted like a Java Exception for IDE usability) if assertion is false and "debugMode" is True. Can be used as a substitute for "assert" when used in a Java based IDE or when the killing of the entire application is warranted.
--
fatalAssert :: (?loc :: CallStack) => Bool -> String -> IO ()
fatalAssert assertion message =
  if not debugMode
    then return()
    else if assertion
            then return()
            else do -- Warning: "callStacks <- return(getCallStack (?loc))" cannot be replaced with "let callStacks = getCallStack (?loc)" because doing so would mess up the call stack.
                   callStacks <- return(getCallStack (?loc)) -- returns [(String, SrcLoc)]
                   let callStack = Data.List.last callStacks -- returns (String, SrcLoc)
                   let callOrigin =  snd callStack -- returns SrcLoc
                   let pathToFileName =  srcLocModule callOrigin
                   let fileName =  srcLocFile callOrigin
                   let lineNumber =  show(srcLocStartLine callOrigin)
                   noMonadThreadId <- myThreadId -- myThreadId returns IO(ThreadID)
                   let threadName =  show noMonadThreadId
                   let threadNameWords = splitOn  " " threadName -- break up thread name along spaces
                   let threadNumberString =  Data.List.last threadNameWords -- this isn't working
                   let fileNameSplit = if (("win" `isInfixOf` os) || ("Win" `isInfixOf` os) || "mingw" `isInfixOf` os)
                                         then splitOn "\\" fileName
                                         else splitOn "/" fileName
                   let fileNameNoCruff = if (length fileNameSplit > 1)
                                                 then last (tail fileNameSplit)
                                                 else head fileNameSplit
                   let lineOne =  message ++ " in" ++ " thread" ++ " " ++ "\"" ++ threadNumberString ++ "\"" ++ " :"
                   let lineTwo =  "    "  ++ "at " ++ pathToFileName ++ ".call" ++ "(" ++ fileNameNoCruff ++ ":" ++ lineNumber ++ ")"
                   let toPrint = if ((Data.List.isInfixOf "win" os) || (Data.List.isInfixOf "Win" os) || (Data.List.isInfixOf "mingw" os))
                            then  lineOne ++ "\r\n" ++ lineTwo ++ "\r\n"
                            else  lineOne ++ "\n" ++ lineTwo ++ "\n" -- linesOneAndTwo = unlines [lineOne, lineTwo])
                   traceIO toPrint
                   die "This application died due to a fatal assertion."

-- | Shorthand for "debugTraceIO". Prints a message with a formatted stack trace.
--
prt :: (?loc :: CallStack) => String -> IO ()
prt = debugTraceIO


-- | This method tests the "debugTraceIO" function.
--
test :: IO()
test = do
  fatalAssert True "Error message"
  debugTraceIO "foobarbaz"
  debugTraceIO "lalalalaaaaa"
  prt "Shorthand for debugTraceIO"
  fatalAssert False "premature death in StackTraceDebug.test"

{-
foobarbaz in thread "1" :
    at Moc.Print.StackTraceDebug.call(StackTraceDebug.hs:98)

lalalalaaaaa in thread "1" :
    at Moc.Print.StackTraceDebug.call(StackTraceDebug.hs:99)

Shorthand for debugTraceIO in thread "1" :
    at Moc.Print.StackTraceDebug.call(StackTraceDebug.hs:100)

premature death in StackTraceDebug.test in thread "1" :
    at Moc.Print.StackTraceDebug.call(StackTraceDebug.hs:101)

This application died due to a fatal assertion.

-}
