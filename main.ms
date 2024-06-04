import "importUtil"
ensureImport "events"
ensureImport "listUtil"
ensureImport "stringUtil"
ensureImport "qa"

ensureImport "coreUtil"

// Note how system-defined symbols can be extended.
//
// e.g. env.addImportPath "./crafting"
env.addImportPath = function(path)
    // `self` == `env`
    if not self.importPaths.contains(path) then
        self.importPaths.push path
    end if
end function

events.eventLoop.onUpdate = function
end function

events.eventLoop.run