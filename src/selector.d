// Start of Document /<repo:codepid/src/selector.d/>

module selector;

import std.algorithm : sort;
import std.path      : baseName;
import std.conv      : to;
import match         : findMatches;
import comparator    : compareBasename;
import dbg           : dbg;

/// Wrapper for sortable items
struct Item
{
    string fullPath;
    string base;
}

/// Comparator wrapper
bool less(Item a, Item b)
{
    return compareBasename(a.base, b.base) < 0;
}

/// LEVEL 1 — chapter ranges: c??-??
string[] listChapterRanges(string root)
{
    dbg(1, "selector: scanning " ~ root ~ " for c??-??");

    auto raw = findMatches(root, "c??-??");

    Item[] items;
    foreach (r; raw)
        items ~= Item(r, baseName(r));

    sort!(less)(items);

    string[] results;
    foreach (i; items)
        results ~= i.fullPath;

    dbg(1, "selector: found " ~ to!string(results.length) ~ " chapter ranges");

    return results;
}

/// LEVEL 2 — chapter numbers: c??
string[] listChapterNumbers(string chapterRangeRoot)
{
    dbg(1, "selector: scanning " ~ chapterRangeRoot ~ " for c??");

    auto raw = findMatches(chapterRangeRoot, "c??");

    Item[] items;
    foreach (r; raw)
        items ~= Item(r, baseName(r));

    sort!(less)(items);

    string[] results;
    foreach (i; items)
        results ~= i.fullPath;

    dbg(1, "selector: found " ~ to!string(results.length) ~ " chapters");

    return results;
}

/// LEVEL 3 — projects: c??_*
string[] listProjects(string chapterNumberRoot)
{
    dbg(1, "selector: scanning " ~ chapterNumberRoot ~ " for c??_*");

    auto raw = findMatches(chapterNumberRoot, "c??_*");

    Item[] items;
    foreach (r; raw)
        items ~= Item(r, baseName(r));

    sort!(less)(items);

    string[] results;
    foreach (i; items)
        results ~= i.fullPath;

    dbg(1, "selector: found " ~ to!string(results.length) ~ " projects");

    return results;
}

// End of Document /<repo:codepid/src/selector.d/>

