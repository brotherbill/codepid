// Start of Document /<repo:codepid/src/vscode.d/>

module vscode;

import std.algorithm : endsWith;
import std.file      : write, mkdirRecurse, dirEntries, SpanMode;
import std.path      : buildPath;
import std.process   : spawnProcess, wait;
import std.stdio     : writeln;
import core.sys.posix.unistd : chdir;

import dbg           : dbg;
import settings      : OUTPUT_EXE_PATH, VSCODE_EXE;

/// Write launch.json into sandbox/.vscode/
void ensureVSCodeConfig(string sandboxProjectPath)
{
    auto vscodeDir  = buildPath(sandboxProjectPath, ".vscode");
    auto launchPath = buildPath(vscodeDir, "launch.json");

    mkdirRecurse(vscodeDir);

    write(launchPath,
q{
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug app",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/app",
            "args": [],
            "cwd": "${workspaceFolder}",
            "stopAtEntry": false,
            "externalConsole": false,
            "MIMode": "gdb",
            "preLaunchTask": null
        }
    ]
}
}
    );

    dbg(1, "vscode: wrote launch.json");
}

/// Build the sandbox project BEFORE launching VS Code.
/// Enumerates all .d files because DMD does NOT expand globs.
void buildSandboxProject(string sandboxProjectPath)
{
    dbg(1, "vscode: building project " ~ sandboxProjectPath);

    // Change working directory into sandbox project
    chdir(sandboxProjectPath.ptr);

    // Collect all .d files in src/
    string[] dFiles;
    foreach (entry; dirEntries("src", SpanMode.shallow))
    {
        if (entry.isFile && endsWith(entry.name, ".d"))
            dFiles ~= entry.name;
    }

    if (dFiles.length == 0)
    {
        dbg(1, "vscode: no .d files found in src/");
        return;
    }

    // DEBUG BUILD (required for breakpoints)
    string[] cmd = ["dmd", "-g", "-debug", "-Isrc"];
    cmd ~= dFiles;
    cmd ~= "-of=" ~ OUTPUT_EXE_PATH;

    dbg(1, "vscode: build command:");
    foreach (c; cmd)
        dbg(1, "  " ~ c);

    auto pid = spawnProcess(cmd);
    wait(pid);

    dbg(1, "vscode: build complete");
}

/// Launch VS Code on the sandbox folder, opening src/app.d:1
void launchVSCode(string sandboxProjectPath)
{
    dbg(1, "vscode: launching VS Code");

    import core.stdc.stdlib : system;

    auto cmd = VSCODE_EXE ~ " " ~ sandboxProjectPath ~ " -g src/app.d:1";
    system(cmd.ptr);

    dbg(1, "vscode: launched");
}

// End of Document /<repo:codepid/src/vscode.d/>

