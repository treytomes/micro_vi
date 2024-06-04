// Load a module into a local variable, allowing it to be reassigned at will.
// e.g. player = import("playerBehaviors")
globals.require = function(moduleName)
	import moduleName
	return locals[moduleName]
end function

globals.iif = function(value, ifTrue, ifFalse)
	if value then return ifTrue
	return ifFalse
end function

// Note how system-defined symbols can be extended.
//
// e.g. env.addImportPath "./crafting"
env.addImportPath = function(path)
    // `self` == `env`
    if not self.importPaths.contains(path) then
        self.importPaths.push path
    end if
end function
