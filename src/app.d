// Start of Document /<repo:codepid/src/app.d/>

module app;

import std.conv    : to;
import std.getopt  : getopt;
import std.stdio   : writeln, write, readln;
import std.string  : strip, split;
import std.process : environment;
import std.path    : baseName;

import selector    : listChapterRanges, listChapterNumbers, listProjects;
import dbg         : dbg, DEBUG_LEVEL;

/// digit check 
bool isDigit(char ch)
{
    return ('0' <= ch && ch <= '9');
}

/// parse basename into structured fields
struct ProjectParts
{
    string chapter;
    string page;
    string section;
    string title;
}

/// extract chapter/page/section/title from basename
ProjectParts parseProject(string base)
{
    auto parts = base.split("_");

    ProjectParts p;

    if (parts.length < 4)
    {
        p.chapter = base;
        p.page    = "";
        p.section = "";
        p.title   = "";
        return p;
    }

    p.chapter = parts[0];
    p.page    = parts[1];
    p.section = parts[2];

    foreach (i; 3 .. parts.length)
    {
        if (i != 3) p.title ~= " ";
        p.title ~= parts[i];
    }

    return p;
}

/// aligned Prax-spine pretty printing
string prettyPrintAligned(string base)
{
    auto p = parseProject(base);

    string chapCol = p.chapter;
    while (chapCol.length <= 3) chapCol ~= " ";

    string pageCol = p.page;
    while (pageCol.length <= 4) pageCol ~= " ";

    string sectCol = p.section;
    while (sectCol.length <= 3) sectCol ~= " ";

    return chapCol ~ pageCol ~ sectCol ~ p.title;
}

/// DRY 1‑based selection helper with aligned pretty printing
string selectIndex(string[] items, string label)
{
    writeln(label ~ ":");

    foreach (i, item; items)
    {
        string base = baseName(item);
        writeln("  ", i + 1, ") ", prettyPrintAligned(base));
    }

    write("Select " ~ label ~ " (1-" ~ to!string(items.length) ~ "): ");
    string raw = strip(readln());

    if (raw.length == 0)
    {
        writeln("Invalid input.");
        return "";
    }

    int idx1 = to!int(raw);

    // index must be in range [1 .. items.length]
    if (!(1 <= idx1 && idx1 <= items.length))
    {
        writeln("Invalid index.");
        return "";
    }

    return items[idx1 - 1];
}

/// app entry point
void main(string[] args)
{
    string dbgRaw = "0";

    getopt(args,
        "debug", &dbgRaw
    );

    int dbgLevel = 0;

    // invalid debug options are ignored (ADOPT‑canonical: garbage → debug level 0)

    bool allDigits = true;
    foreach (ch; dbgRaw)
    {
        if (!isDigit(ch))
        {
            allDigits = false;
            break;
        }
    }

    if (allDigits)
    {
        int lvl = to!int(dbgRaw);

        if (lvl <= 0)
        {
            dbgLevel = 0;
        }
        else if (lvl == 1 || lvl == 2 || lvl == 3)
        {
            dbgLevel = lvl;
        }
        else
        {
            dbgLevel = 0;
        }
    }
    else
    {
        dbgLevel = 0;
    }

    DEBUG_LEVEL = dbgLevel;
    dbg(1, "debug level = " ~ to!string(DEBUG_LEVEL));

    string home = environment["HOME"];
    string root = home ~ "/dev/repos/programming-in-d";

    dbg(1, "Prax spine root: " ~ root);

    auto ranges = listChapterRanges(root);
    dbg(1, "app: chapter ranges count = " ~ to!string(ranges.length));
    auto rangeRoot = selectIndex(ranges, "Chapter Range");
    if (rangeRoot.length == 0) return;
    dbg(1, "app: selected chapter range " ~ baseName(rangeRoot));

    auto chapters = listChapterNumbers(rangeRoot);
    dbg(1, "app: chapters count = " ~ to!string(chapters.length));
    auto chapterRoot = selectIndex(chapters, "Chapter");
    if (chapterRoot.length == 0) return;
    dbg(1, "app: selected chapter " ~ baseName(chapterRoot));

    auto projects = listProjects(chapterRoot);
    dbg(1, "app: projects count = " ~ to!string(projects.length));
    auto projectRoot = selectIndex(projects, "Project");
    if (projectRoot.length == 0) return;
    dbg(1, "app: selected project " ~ baseName(projectRoot));

    writeln("Selected project: ", prettyPrintAligned(baseName(projectRoot)));
}

// End of Document /<repo:codepid/src/app.d/>

