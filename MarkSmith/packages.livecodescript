Script "marksmith_Packages"

function isPackage pFolder
    put revMacFromUnixPath(pFolder) & ":" into pFolder
    put "package folder of (info for alias " & quote & pFolder & quote & ")" into tScr
    do tScr as applescript
    return the result
end isPackage


function thePackages pFolder
    put revMacFromUnixPath(pFolder) into pFolder
    
    put "tell application" && quote & "Finder" & quote & cr & "packages of folder" \
    && quote & pFolder & quote & cr & "end tell" into tScr
    do tScr as applescript
    put the result into tList
    replace comma with cr in tList
     
    repeat for each line L in tList
        get wordoffset("file", L)
        put word it + 1 of L & cr after tPackages
    end repeat
    replace quote with empty in tPackages
    return char 1 to -2 of tPackages
end thePackages