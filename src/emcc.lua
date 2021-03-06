---
-- emcc.lua
-- Provides emcc-specific configuration strings.
-- Copyright (c) 2002-2015 Jason Perkins and the Premake project
---

	local p = premake

	p.tools.emcc = {}
	local emcc = p.tools.emcc

	local project = p.project
	local config = p.config


--
-- Returns list of C preprocessor flags for a configuration.
--

	emcc.cppflags = {
		system = {
			haiku = "-MMD",
			wii = { "-MMD", "-MP", "-I$(LIBOGC_INC)", "$(MACHDEP)" },
			_ = { "-MMD", "-MP" }
		}
	}

	emcc.arargs = 'rcs'

	function emcc.getcppflags(cfg)
		local flags = config.mapFlags(cfg, emcc.cppflags)
		return flags
	end


--
-- Returns list of C compiler flags for a configuration.
--
	emcc.shared = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
		},
		flags = {
			FatalCompileWarnings = "-Werror",
			LinkTimeOptimization = "-flto",
			NoFramePointer = "-fomit-frame-pointer",
			ShadowedVariables = "-Wshadow",
			UndefinedIdentifiers = "-Wundef",
		},
		floatingpoint = {
			Fast = "-ffast-math",
			Strict = "-ffloat-store",
		},
		strictaliasing = {
			Off = "-fno-strict-aliasing",
			Level1 = { "-fstrict-aliasing", "-Wstrict-aliasing=1" },
			Level2 = { "-fstrict-aliasing", "-Wstrict-aliasing=2" },
			Level3 = { "-fstrict-aliasing", "-Wstrict-aliasing=3" },
		},
		optimize = {
			Off = "-O0",
			On = "-O2",
			Debug = "-Og",
			Full = "-O3",
			Size = "-Os",
			Speed = "-O3",
		},
		pic = {
			On = "-fPIC",
		},
		vectorextensions = {
			AVX = "-mavx",
			AVX2 = "-mavx2",
			SSE = "-msse",
			SSE2 = "-msse2",
			SSE3 = "-msse3",
			SSSE3 = "-mssse3",
			["SSE4.1"] = "-msse4.1",
		},
		warnings = {
			Extra = "-Wall -Wextra",
			Off = "-w",
		},
		symbols = {
			On = "-g"
		}
	}

	emcc.cflags = {
		flags = {
			["C90"] = "-std=gnu90",
			["C99"] = "-std=gnu99",
			["C11"] = "-std=gnu11",
		},
		language = {
			["C89"] = "-std=c89",
			["C90"] = "-std=c90",
			["C99"] = "-std=c99",
			["C11"] = "-std=c11",
			["gnu89"] = "-std=gnu89",
			["gnu90"] = "-std=gnu90",
			["gnu99"] = "-std=gnu99",
			["gnu11"] = "-std=gnu11",
		}
	}

	function emcc.getcflags(cfg)
		local shared_flags = config.mapFlags(cfg, emcc.shared)
		local cflags = config.mapFlags(cfg, emcc.cflags)
		local flags = table.join(shared_flags, cflags)
		flags = table.join(flags, emcc.getwarnings(cfg))
		return flags
	end

	function emcc.getwarnings(cfg)
		local result = {}
		for _, enable in ipairs(cfg.enablewarnings) do
			table.insert(result, '-W' .. enable)
		end
		for _, disable in ipairs(cfg.disablewarnings) do
			table.insert(result, '-Wno-' .. disable)
		end
		for _, fatal in ipairs(cfg.fatalwarnings) do
			table.insert(result, '-Werror=' .. fatal)
		end
		return result
	end


--
-- Returns list of C++ compiler flags for a configuration.
--

	emcc.cxxflags = {
		exceptionhandling = {
			Off = "-fno-exceptions"
		},
		flags = {
			NoBufferSecurityCheck = "-fno-stack-protector",
			["C++11"] = "-std=c++11",
			["C++14"] = "-std=c++14",
		},
		language = {
			["C++98"] = "-std=c++98",
			["C++11"] = "-std=c++11",
			["C++14"] = "-std=c++14",
			["C++17"] = "-std=c++17",
			["gnu++98"] = "-std=gnu++98",
			["gnu++11"] = "-std=gnu++11",
			["gnu++14"] = "-std=gnu++14",
			["gnu++17"] = "-std=gnu++17",
		},
		rtti = {
			Off = "-fno-rtti"
		}
	}

	function emcc.getcxxflags(cfg)
		local shared_flags = config.mapFlags(cfg, emcc.shared)
		local cxxflags = config.mapFlags(cfg, emcc.cxxflags)
		local flags = table.join(shared_flags, cxxflags)
		flags = table.join(flags, emcc.getwarnings(cfg))
		return flags
	end


--
-- Decorate defines for the emcc command line.
--

	function emcc.getdefines(defines)
		local result = {}
		for _, define in ipairs(defines) do
			table.insert(result, '-D' .. p.esc(define))
		end
		return result
	end

	function emcc.getundefines(undefines)
		local result = {}
		for _, undefine in ipairs(undefines) do
			table.insert(result, '-U' .. p.esc(undefine))
		end
		return result
	end


--
-- Returns a list of forced include files, decorated for the compiler
-- command line.
--
-- @param cfg
--    The project configuration.
-- @return
--    An array of force include files with the appropriate flags.
--

	function emcc.getforceincludes(cfg)
		local result = {}

		table.foreachi(cfg.forceincludes, function(value)
			local fn = project.getrelative(cfg.project, value)
			table.insert(result, string.format('-include %s', p.quoted(fn)))
		end)

		return result
	end


--
-- Decorate include file search paths for the emcc command line.
--

	function emcc.getincludedirs(cfg, dirs, sysdirs)
		local result = {}
		for _, dir in ipairs(dirs) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-I' .. p.quoted(dir))
		end
		for _, dir in ipairs(sysdirs or {}) do
			dir = project.getrelative(cfg.project, dir)
			table.insert(result, '-isystem ' .. p.quoted(dir))
		end
		return result
	end

--
-- Return a list of decorated rpaths
--

	function emcc.getrunpathdirs(cfg, dirs)
		local result = {}

		if not ((cfg.system == p.MACOSX)
				or (cfg.system == p.LINUX)) then
			return result
		end

		local rpaths = {}

		-- User defined runpath search paths
		for _, fullpath in ipairs(cfg.runpathdirs) do
			local rpath = path.getrelative(cfg.buildtarget.directory, fullpath)
			if not (table.contains(rpaths, rpath)) then
				table.insert(rpaths, rpath)
			end
		end

		-- Automatically add linked shared libraries path relative to target directory
		for _, sibling in ipairs(config.getlinks(cfg, "siblings", "object")) do
			if (sibling.kind == p.SHAREDLIB) then
				local fullpath = sibling.linktarget.directory
				local rpath = path.getrelative(cfg.buildtarget.directory, fullpath)
				if not (table.contains(rpaths, rpath)) then
					table.insert(rpaths, rpath)
				end
			end
		end

		for _, rpath in ipairs(rpaths) do
			if (cfg.system == p.MACOSX) then
				rpath = "@loader_path/" .. rpath
			elseif (cfg.system == p.LINUX) then
				rpath = iif(rpath == ".", "", "/" .. rpath)
				rpath = "$$ORIGIN" .. rpath
			end

			table.insert(result, "-Wl,-rpath,'" .. rpath .. "'")
		end

		return result
	end

--
-- Return a list of LDFLAGS for a specific configuration.
--

	function emcc.ldsymbols(cfg)
		-- OS X has a bug, see http://lists.apple.com/archives/Darwin-dev/2006/Sep/msg00084.html
		return iif(cfg.system == p.MACOSX, "-Wl,-x", "-s")
	end

	emcc.ldflags = {
		architecture = {
			x86 = "-m32",
			x86_64 = "-m64",
		},
		flags = {
			LinkTimeOptimization = "-flto",
		},
		kind = {
			SharedLib = function(cfg)
				local r = { iif(cfg.system == p.MACOSX, "-dynamiclib", "-shared") }
				if cfg.system == p.WINDOWS and not cfg.flags.NoImportLib then
					table.insert(r, '-Wl,--out-implib="' .. cfg.linktarget.relpath .. '"')
				elseif cfg.system == p.LINUX then
					table.insert(r, '-Wl,-soname=' .. p.quoted(cfg.linktarget.name))
				elseif cfg.system == p.MACOSX then
					table.insert(r, '-Wl,-install_name,' .. p.quoted('@rpath/' .. cfg.linktarget.name))
				end
				return r
			end,
			WindowedApp = function(cfg)
				if cfg.system == p.WINDOWS then return "-mwindows" end
			end,
		},
		system = {
			wii = "$(MACHDEP)",
		},
		symbols = {
			Off = emcc.ldsymbols,
			Default = emcc.ldsymbols,
		}
	}

	function emcc.getldflags(cfg)
		local flags = config.mapFlags(cfg, emcc.ldflags)
		return flags
	end



--
-- Return a list of decorated additional libraries directories.
--

	emcc.libraryDirectories = {
		architecture = {
			x86 = function (cfg)
				local r = {}
				if cfg.system ~= p.MACOSX then
					table.insert (r, "-L/usr/lib32")
				end
				return r
			end,
			x86_64 = function (cfg)
				local r = {}
				if cfg.system ~= p.MACOSX then
					table.insert (r, "-L/usr/lib64")
				end
				return r
			end,
		},
		system = {
			wii = "-L$(LIBOGC_LIB)",
		}
	}

	function emcc.getLibraryDirectories(cfg)
		local flags = config.mapFlags(cfg, emcc.libraryDirectories)

		-- Scan the list of linked libraries. If any are referenced with
		-- paths, add those to the list of library search paths. The call
		-- config.getlinks() all includes cfg.libdirs.
		for _, dir in ipairs(config.getlinks(cfg, "system", "directory")) do
			table.insert(flags, '-L' .. p.quoted(dir))
		end

		if cfg.flags.RelativeLinks then
			for _, dir in ipairs(config.getlinks(cfg, "siblings", "directory")) do
				local libFlag = "-L" .. p.project.getrelative(cfg.project, dir)
				if not table.contains(flags, libFlag) then
					table.insert(flags, libFlag)
				end
			end
		end

		for _, dir in ipairs(cfg.syslibdirs) do
			table.insert(flags, '-L' .. p.quoted(dir))
		end

		return flags
	end



--
-- Return the list of libraries to link, decorated with flags as needed.
--

	function emcc.getlinks(cfg, systemonly, nogroups)
		local result = {}

		if not systemonly then
			if cfg.flags.RelativeLinks then
				local libFiles = config.getlinks(cfg, "siblings", "basename")
				for _, link in ipairs(libFiles) do
					if string.startswith(link, "lib") then
						link = link:sub(4)
					end
					table.insert(result, "-l" .. link)
				end
			else
				-- Don't use the -l form for sibling libraries, since they may have
				-- custom prefixes or extensions that will confuse the linker. Instead
				-- just list out the full relative path to the library.
				result = config.getlinks(cfg, "siblings", "fullpath")
			end
		end

		if not nogroups and #result > 1 and (cfg.linkgroups == p.ON) then
			table.insert(result, 1, "-Wl,--start-group")
			table.insert(result, "-Wl,--end-group")
		end

		-- The "-l" flag is fine for system libraries
		local links = config.getlinks(cfg, "system", "fullpath")
		local static_syslibs = {"-Wl,-Bstatic"}
		local shared_syslibs = {}

		for _, link in ipairs(links) do
			if path.isframework(link) then
				table.insert(result, "-framework")
				table.insert(result, path.getbasename(link))
			elseif path.isobjectfile(link) then
				table.insert(result, link)
			else
				local endswith = function(s, ptrn)
					return ptrn == string.sub(s, -string.len(ptrn))
				end
				local name = path.getname(link)
				-- Check whether link mode decorator is present
				if endswith(name, ":static") then
					name = string.sub(name, 0, -8)
					table.insert(static_syslibs, "-l" .. name)
				elseif endswith(name, ":shared") then
					name = string.sub(name, 0, -8)
					table.insert(shared_syslibs, "-l" .. name)
				else
					table.insert(shared_syslibs, "-l" .. name)
				end
			end
		end

		local move = function(a1, a2)
			local t = #a2
			for i = 1, #a1 do a2[t + i] = a1[i] end
		end
		if #static_syslibs > 1 then
			table.insert(static_syslibs, "-Wl,-Bdynamic")
			move(static_syslibs, result)
	    end
		move(shared_syslibs, result)

		return result
	end


--
-- Returns makefile-specific configuration rules.
--

	emcc.makesettings = {
		system = {
			wii = [[
  ifeq ($(strip $(DEVKITPPC)),)
    $(error "DEVKITPPC environment variable is not set")'
  endif
  include $(DEVKITPPC)/wii_rules']]
		}
	}

	function emcc.getmakesettings(cfg)
		local settings = config.mapFlags(cfg, emcc.makesettings)
		return table.concat(settings)
	end


--
-- Retrieves the executable command name for a tool, based on the
-- provided configuration and the operating environment.
--
-- @param cfg
--    The configuration to query.
-- @param tool
--    The tool to fetch, one of "cc" for the C compiler, "cxx" for
--    the C++ compiler, or "ar" for the static linker.
-- @return
--    The executable command name for a tool, or nil if the system's
--    default value should be used.
--

	emcc.tools = {
		cc = "emcc",
		cxx = "emcc",
		ar = "llvm-ar",
		rc = "emcc"
	}

	function emcc.gettoolname(cfg, tool)
		return emcc.tools[tool]
	end
