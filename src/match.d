// Start of Document /<repo:codepid/src/match.d/>

module match;

import std.algorithm : endsWith, sort;
import std.conv      : to;
import std.file      : dirEntries, SpanMode;
import std.path      : baseName, buildPath;
import std.stdio     : writeln;

import dbg           : dbg;

/// Manual prefix check (DMD‑compatible)
bool hasPrefix(string s, string p)
{
    return s.length >= p.length &&
           s[0 .. p.length] == p;
}

/// Manual substring check (DMD‑compatible)
bool hasSubstring(string s, string sub)
{
    auto n = s.length;
    auto m = sub.length;

    if (m == 0) return true;
    if (m > n) return false;

    foreach (i; 0 .. n - m + 1)
    {
        if (s[i .. i + m] == sub)
            return true;
    }
    return false;
}

/// Simple pattern matcher for Prax spine.
bool matchPattern(string name, string pattern)
{
    // "*.d"
    if (pattern == "*.d")
        return endsWith(name, ".d");

    // "c??"
    if (pattern == "c??")
        return hasPrefix(name, "c") &&
               name.length == 3;

    // "c??-??"
    if (pattern == "c??-??")
        return hasPrefix(name, "c") &&
               name.length == 6 &&
               name[3] == '-';

    // "c??_*"
    if (pattern == "c??_*")
        return hasPrefix(name, "c") &&
               hasSubstring(name, "_");

    // fallback: exact match
    return name == pattern;
}

/// findMatches — return full paths of entries matching pattern
string[] findMatches(string root, string pattern)
{
    dbg(1, "match: scanning " ~ root ~ " for pattern " ~ pattern);

    string[] results;

    foreach (entry; dirEntries(root, SpanMode.shallow))
    {
        auto name = baseName(entry.name);

        if (matchPattern(name, pattern))
        {
            auto full = buildPath(root, name);
            results ~= full;
        }
    }

    // stable alphabetical ordering
    sort(results);

    dbg(1, "match: found " ~ to!string(results.length) ~ " matches");
    return results;
}

// End of Document /<repo:codepid/src/match.d/>

