// Start of Document /<repo:codepid/src/tasks.d/>

module tasks;

import std.file : write, mkdirRecurse;
import std.path : buildPath;
import std.stdio : writeln;

import dbg : dbg;

/// Write tasks.json into sandbox/.vscode/
void writeTasks(string sandboxProjectPath)
{
    auto vscodeDir  = buildPath(sandboxProjectPath, ".vscode");
    auto tasksPath  = buildPath(vscodeDir, "tasks.json");

    mkdirRecurse(vscodeDir);

    write(tasksPath,
q{
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build app",
            "type": "shell",
            "command": "dmd -g -debug -Isrc src/app.d -of=app",
            "group": "build",
            "problemMatcher": []
        }
    ]
}
}
    );

    dbg(1, "tasks: wrote tasks.json");
}

// End of Document /<repo:codepid/src/tasks.d/>

