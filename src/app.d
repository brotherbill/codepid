// Start of Document /<repo:codepid/src/app.d/>

module app;

import std.conv    : to;
import std.getopt  : getopt;
import std.stdio   : writeln, write, readln;
import std.string  : strip, split;
import std.process : environment;
import std.path    : baseName;
import std.file    : readText;

import selector    : runSelector;
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
        if (!(i == 3)) p.title ~= " ";
        p.title ~= parts[i];
    }

    return p;
}

/// aligned Prax-spine pretty printing
string prettyPrintAligned(string base)
{
    auto p = parseProject(base);

    string chapCol = p.chapter;
    while (!(chapCol.length > 3)) chapCol ~= " ";

    string pageCol = p.page;
    while (!(pageCol.length > 4)) pageCol ~= " ";

    string sectCol = p.section;
    while (!(sectCol.length > 3)) sectCol ~= " ";

    return chapCol ~ pageCol ~ sectCol ~ p.title;
}

/// app entry point
void main(string[] args)
{
    string dbgRaw = "0";

    getopt(args,
        "debug", &dbgRaw
    );

    int dbgLevel = 0;

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

        if (!(lvl > 0))
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

    // token optional: bare ./codepid → tree descent
    string token;

    if (args.length <= 1)
    {
        token = "";
        dbg(1, "token = <empty> (tree descent mode)");
    }
    else
    {
        token = args[1];
        dbg(1, "token = " ~ token);
    }

    // selector UI
    auto chosen = runSelector(token);

    if (chosen.length == 0)
    {
        writeln("No selection.");
        return;
    }

    dbg(1, "selected basename = " ~ chosen);

    // load file from Prax spine
    auto home = environment["HOME"];
    auto root = home ~ "/dev/repos/programming-in-d";

    auto path = root ~ "/" ~ chosen;
    string content;

    try {
        content = readText(path);
    } catch (Exception e) {
        writeln("Cannot read file: ", path);
        return;
    }

    writeln("----- BEGIN FILE -----");
    writeln(content);
    writeln("----- END FILE -----");

    writeln("Selected project: ", prettyPrintAligned(baseName(chosen)));
}

// End of Document /<repo:codepid/src/app.d/>

