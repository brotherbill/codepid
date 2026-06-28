// Start of Document \<repo:codepid/src/sandbox.d\>

module sandbox;

import std.algorithm : endsWith;
import std.file      : mkdirRecurse, copy, dirEntries, SpanMode, exists;
import std.path      : baseName, dirName;
import std.stdio     : writeln;

import dbg           : dbg;
import settings      : SANDBOX_ROOT;

/// Return sandbox project path for a given project name.
string getSandboxProjectPath(string projectName)
{
    return SANDBOX_ROOT ~ "/" ~ projectName;
}

/// Check whether sandbox project already exists (reuse mode).
bool sandboxExists(string projectName)
{
    auto path = getSandboxProjectPath(projectName) ~ "/src/app.d";
    return exists(path);
}

/// Prepare sandbox only if it does NOT already exist.
/// Otherwise, reuse existing sandbox.
string prepareSandbox(string selectedPath, string sandboxRoot)
{
    dbg(1, "sandbox: selectedPath = " ~ selectedPath);

    if (selectedPath.length == 0)
    {
        dbg(1, "sandbox: no file selected; skipping sandbox preparation");
        return "";
    }

    // Exercise directory
    auto exerciseDir = dirName(selectedPath);
    dbg(1, "sandbox: exerciseDir = " ~ exerciseDir);

    // Project directory = exerciseDir
    auto projectDir = exerciseDir;
    dbg(1, "sandbox: projectDir  = " ~ projectDir);

    // Project name
    auto projectName = baseName(projectDir);
    dbg(1, "sandbox: projectName = " ~ projectName);

    // Sandbox project path
    auto destProject = sandboxRoot ~ "/" ~ projectName;
    auto destSrc     = destProject ~ "/src";

    // REUSE MODE: If sandbox already exists, skip regeneration
    if (sandboxExists(projectName))
    {
        dbg(1, "sandbox: reuse mode — sandbox already exists");
        return destProject;
    }

    dbg(1, "sandbox: fresh mode — creating new sandbox");

    // Create directories
    mkdirRecurse(destSrc);

    // Copy ALL .d files from exerciseDir → destSrc
    foreach (entry; dirEntries(exerciseDir, SpanMode.shallow))
    {
        if (!entry.isFile) continue;

        auto name = entry.name;
        if (endsWith(name, ".d"))
        {
            auto destFile = destSrc ~ "/" ~ baseName(name);
            dbg(1, "sandbox: copying " ~ name ~ " → " ~ destFile);
            copy(name, destFile);
        }
    }

    return destProject;
}

// End of Document \<repo:codepid/src/sandbox.d\>

