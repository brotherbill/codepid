// Start of Document /<repo:codepid/src/match.d/>

module match;

import std.file     : dirEntries, SpanMode;
import std.path     : baseName;
import std.string   : endsWith;
import std.algorithm: canFind;
import std.conv     : to;
import dbg          : dbg;

/// find entries matching a simple pattern like "c??-??", "c??", "c??_*"
string[] findMatches(string root, string pattern)
{
    dbg(1, "match: scanning " ~ root ~ " for pattern " ~ pattern);

    string[] results;

    foreach (entry; dirEntries(root, SpanMode.shallow))
    {
        auto name = baseName(entry.name);

        // very simple pattern handling for this Prax spine
        bool ok = false;

        if (pattern == "c??-??")
            ok = name.length == 6 && name[0] == 'c';
        else if (pattern == "c??")
            ok = name.length == 3 && name[0] == 'c';
        else if (pattern == "c??_*")
            ok = name.length >= 4 && name[0] == 'c' && canFind(name, "_");

        if (ok)
            results ~= entry.name;
    }

    dbg(1, "match: found " ~ to!string(results.length) ~ " matches");

    return results;
}

// End of Document /<repo:codepid/src/match.d/>

