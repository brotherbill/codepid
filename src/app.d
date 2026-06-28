// Start of Document /<repo:codepid/src/app.d/>

module app;

import std.conv   : to;
import std.path   : baseName;
import std.stdio  : readln, write, writeln;
import std.string : strip;

import dbg        : dbg;
import sandbox    : prepareSandbox, sandboxExists, getSandboxProjectPath;
import selector   : listChapters, listProjects, listExercises;
import settings   : SANDBOX_ROOT;
import tasks      : writeTasks;
import vscode     : ensureVSCodeConfig, buildSandboxProject, launchVSCode;

enum string CODEPID_VERSION = "v0.7.0";

void main()
{
    writeln("codepid ", CODEPID_VERSION);

    //
    // 1. CHAPTER SELECTION UI
    //
    auto chapters = listChapters();
    writeln("available chapters:");
    foreach (i, ch; chapters)
        writeln(i + 1, ": ", ch);

    write("select chapter index: ");
    auto chapterIdx = to!int(strip(readln())) - 1;
    auto chapterRoot = chapters[chapterIdx];
    dbg(1, "app: selected chapter " ~ chapterRoot);

    //
    // 2. PROJECT SELECTION UI
    //
    auto projects = listProjects(chapterRoot);
    writeln("available projects:");
    foreach (i, pr; projects)
        writeln(i + 1, ": ", pr);

    write("select project index: ");
    auto projectIdx = to!int(strip(readln())) - 1;
    auto projectRoot = projects[projectIdx];
    dbg(1, "app: selected project " ~ projectRoot);

    //
    // 3. EXERCISE SELECTION UI
    //
    auto exercises = listExercises(projectRoot);
    writeln("available exercises:");
    foreach (i, ex; exercises)
        writeln(i + 1, ": ", ex);

    write("select exercise index: ");
    auto exerciseIdx = to!int(strip(readln())) - 1;
    auto exerciseRoot = exercises[exerciseIdx];
    dbg(1, "app: selected exercise " ~ exerciseRoot);

    //
    // 4. SANDBOX HYDRATION OR REUSE
    //
    auto projectName = baseName(exerciseRoot);
    auto projectPath = getSandboxProjectPath(projectName);

    if (sandboxExists(projectName))
    {
        dbg(1, "app: reuse mode — opening existing sandbox");

        ensureVSCodeConfig(projectPath);
        writeTasks(projectPath);
        buildSandboxProject(projectPath);
        launchVSCode(projectPath);

        writeln("sandbox project (reuse): ", projectPath);
        return;
    }

    dbg(1, "app: fresh mode — creating sandbox");

    // Hydrate ALL .d files in the exercise directory
    projectPath = prepareSandbox(exerciseRoot ~ "/app.d", SANDBOX_ROOT);

    //
    // 5. BUILD + VS CODE + TASKS
    //
    ensureVSCodeConfig(projectPath);
    writeTasks(projectPath);
    buildSandboxProject(projectPath);
    launchVSCode(projectPath);

    writeln("sandbox project (fresh): ", projectPath);
}

// End of Document /<repo:codepid/src/app.d/>

