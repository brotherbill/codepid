// Start of Document /<repo:codepid/src/selector.d/>

module selector;

import std.conv    : to;
import std.stdio   : writeln, write, readln;
import std.string  : strip;

import dbg         : dbg;
import match       : findMatches;

/// listChapters — return list of chapter directories
string[] listChapters()
{
    return findMatches("/home/bb/dev/repos/programming-in-d", "c??-??");
}

/// listProjects — return list of project directories inside a chapter
string[] listProjects(string chapterRoot)
{
    return findMatches(chapterRoot, "c??");
}

/// listExercises — return list of exercise directories inside a project
string[] listExercises(string projectRoot)
{
    return findMatches(projectRoot, "c??_*");
}

// End of Document /<repo:codepid/src/selector.d/>

