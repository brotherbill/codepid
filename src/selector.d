// Start of Document /<repo:codepid/src/selector.d/>

module selector;

import std.conv    : to;
import std.stdio   : writeln, write, readln;
import std.file    : dirEntries, SpanMode;
import std.path    : baseName;
import std.string  : strip;
import std.process : environment;

import match       : findMatches;
import comparator  : basenameLess;
import dbg         : dbg, DEBUG_LEVEL;

/// ASCII digit helper
private bool isDigit(char c)
{
    return ('0' <= c && c <= '9');
}

/// simple lexicographic sort using basenameLess
private void sortBasenames(ref string[] arr)
{
    size_t n = arr.length;
    size_t i = 0;

    while (i < n)
    {
        size_t j = i + 1;
        while (j < n)
        {
            if (basenameLess(arr[j], arr[i]))
            {
                auto tmp = arr[i];
                arr[i] = arr[j];
                arr[j] = tmp;
            }
            j = j + 1;
        }
        i = i + 1;
    }
}

/// 1-based selection helper
private string selectIndex(string[] items, string label)
{
    dbg(2, "selector: selectIndex(" ~ label ~ ") count=" ~ items.length.to!string);

    if (items.length == 0)
    {
        writeln("No ", label, " entries.");
        return "";
    }

    writeln(label, ":");

    size_t i = 0;
    while (i < items.length)
    {
        auto base = baseName(items[i]);
        auto idx  = i + 1;
        writeln("  ", idx, ") ", base);
        i = i + 1;
    }

    write("Select ", label, " (1-", items.length, "): ");
    auto raw = readln();
    raw = raw.strip();

    if (raw.length == 0)
    {
        writeln("Invalid input.");
        return "";
    }

    int idx1 = 0;
    size_t p = 0;

    while (p < raw.length && isDigit(raw[p]))
    {
        idx1 = idx1 * 10 + (raw[p] - '0');
        p = p + 1;
    }

    if (!(1 <= idx1 && idx1 <= items.length))
    {
        writeln("Invalid index.");
        return "";
    }

    return items[idx1 - 1];
}

/// list chapter ranges: cNN-NN
private string[] listChapterRanges(string root)
{
    dbg(2, "selector: scanning ranges in root = " ~ root);

    string[] acc;

    foreach (entry; dirEntries(root, SpanMode.shallow))
    {
        dbg(2, "selector: found entry = " ~ entry.name);

        if (!entry.isDir)
        {
            dbg(2, "selector: reject (not dir)");
            continue;
        }

        auto base = baseName(entry.name);
        dbg(2, "selector: base = " ~ base);

        if (base.length == 0)
        {
            dbg(2, "selector: reject (empty name)");
            continue;
        }

        if (!(base[0] == 'c' || base[0] == 'C'))
        {
            dbg(2, "selector: reject (not starting with c)");
            continue;
        }

        size_t i = 1;
        bool ok = true;

        // digits until '-'
        while (i < base.length && base[i] != '-')
        {
            if (!isDigit(base[i]))
            {
                dbg(2, "selector: reject (non-digit before '-')");
                ok = false;
                break;
            }
            i = i + 1;
        }

        if (!ok) continue;

        if (i == base.length)
        {
            dbg(2, "selector: reject (no '-')");
            continue;
        }

        if (base[i] != '-')
        {
            dbg(2, "selector: reject (missing '-')");
            continue;
        }

        // digits after '-'
        i = i + 1;
        while (i < base.length)
        {
            if (!isDigit(base[i]))
            {
                dbg(2, "selector: reject (non-digit after '-')");
                ok = false;
                break;
            }
            i = i + 1;
        }

        if (!ok) continue;

        dbg(2, "selector: ACCEPT range = " ~ entry.name);
        acc ~= entry.name;
    }

    sortBasenames(acc);
    dbg(2, "selector: total accepted ranges = " ~ acc.length.to!string);

    return acc;
}

/// list chapters inside a range directory: cNN
private string[] listChapters(string rangeRoot)
{
    dbg(2, "selector: scanning chapters in rangeRoot = " ~ rangeRoot);

    string[] acc;

    foreach (entry; dirEntries(rangeRoot, SpanMode.shallow))
    {
        dbg(2, "selector: found entry = " ~ entry.name);

        if (!entry.isDir)
        {
            dbg(2, "selector: reject (not dir)");
            continue;
        }

        auto base = baseName(entry.name);
        dbg(2, "selector: base = " ~ base);

        if (base.length == 0)
        {
            dbg(2, "selector: reject (empty)");
            continue;
        }

        if (!(base[0] == 'c' || base[0] == 'C'))
        {
            dbg(2, "selector: reject (not starting with c)");
            continue;
        }

        size_t i = 1;
        bool ok = true;

        while (i < base.length)
        {
            if (!isDigit(base[i]))
            {
                dbg(2, "selector: reject (non-digit in chapter)");
                ok = false;
                break;
            }
            i = i + 1;
        }

        if (!ok) continue;

        dbg(2, "selector: ACCEPT chapter = " ~ entry.name);
        acc ~= entry.name;
    }

    sortBasenames(acc);
    dbg(2, "selector: total accepted chapters = " ~ acc.length.to!string);

    return acc;
}

/// list projects inside a chapter directory
private string[] listProjects(string chapterRoot)
{
    dbg(2, "selector: scanning projects in chapterRoot = " ~ chapterRoot);

    string[] full;
    string[] bases;

    foreach (entry; dirEntries(chapterRoot, SpanMode.shallow))
    {
        dbg(2, "selector: found entry = " ~ entry.name);

        if (!entry.isDir)
        {
            dbg(2, "selector: reject (not dir)");
            continue;
        }

        auto bn = baseName(entry.name);

        dbg(2, "selector: ACCEPT project = " ~ bn);

        full  ~= entry.name;
        bases ~= bn;
    }

    // sort basenames
    sortBasenames(bases);

    dbg(2, "selector: sorted project basenames:");

    size_t i = 0;
    while (i < bases.length)
    {
        dbg(2, "  " ~ bases[i]);
        i = i + 1;
    }

    // rebuild full paths in sorted order
    string[] sortedFull;

    i = 0;
    while (i < bases.length)
    {
        size_t j = 0;
        while (j < full.length)
        {
            if (baseName(full[j]) == bases[i])
            {
                sortedFull ~= full[j];
                break;
            }
            j = j + 1;
        }
        i = i + 1;
    }

    dbg(2, "selector: total accepted projects = " ~ sortedFull.length.to!string);

    return sortedFull;
}

/// runSelector — two modes:
/// 1) token == ""  → tree descent (Range → Chapter → Project)
/// 2) token != ""  → token-based match via findMatches
string runSelector(string token)
{
    auto home = environment["HOME"];
    auto root = home ~ "/dev/repos/programming-in-d";

    dbg(2, "selector: runSelector token='" ~ token ~ "'");
    dbg(2, "selector: root = " ~ root);

    // MODE 1: bare ./codepid → tree descending
    if (token.length == 0)
    {
        dbg(2, "selector: MODE = tree descent");

        auto ranges = listChapterRanges(root);
        auto rangeRoot = selectIndex(ranges, "Chapter Range");
        if (rangeRoot.length == 0)
        {
            writeln("No selection.");
            return "";
        }

        auto chapters = listChapters(rangeRoot);
        auto chapterRoot = selectIndex(chapters, "Chapter");
        if (chapterRoot.length == 0)
        {
            writeln("No selection.");
            return "";
        }

        auto projects = listProjects(chapterRoot);
        auto projectRoot = selectIndex(projects, "Project");
        if (projectRoot.length == 0)
        {
            writeln("No selection.");
            return "";
        }

        return baseName(projectRoot);
    }

    // MODE 2: token provided → use match.d
    dbg(2, "selector: MODE = token match");

    auto matches = findMatches(root, token);

    dbg(2, "selector: matches found = " ~ matches.length.to!string);

    if (matches.length == 0)
    {
        writeln("No matches.");
        return "";
    }

    sortBasenames(matches);

    size_t i = 0;
    while (i < matches.length)
    {
        auto idx = i + 1;
        writeln(idx, ": ", matches[i]);
        i = i + 1;
    }

    write("Select number: ");
    auto line = readln();
    if (line.length == 0) return "";

    line = line.strip();
    int choice = 0;

    size_t p = 0;
    while (p < line.length && isDigit(line[p]))
    {
        choice = choice * 10 + (line[p] - '0');
        p = p + 1;
    }

    if (choice <= 0) return "";
    auto index = choice - 1;

    if (index < matches.length)
    {
        return matches[index];
    }

    return "";
}

// End of Document /<repo:codepid/src/selector.d/>

