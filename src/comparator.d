// Start of Document /<repo:codepid/src/comparator.d/>

module comparator;

import std.string : split;
import std.conv   : to;

import dbg        : dbg;

/// section class
enum SectionClass
{
    plain,
    numeric,
    alpha,
    mixed
}

/// classify section tokens
SectionClass classifySection(string s)
{
    bool hasDigit = false;
    bool hasAlpha = false;

    foreach (ch; s)
    {
        if (ch >= '0' && ch <= '9')
            hasDigit = true;
        else if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z'))
            hasAlpha = true;
    }

    if (hasDigit && hasAlpha) return SectionClass.mixed;
    if (hasDigit)             return SectionClass.numeric;
    if (hasAlpha)             return SectionClass.alpha;
    return SectionClass.plain;
}

/// parse leading digits starting at index `start`
int parseLeadingInt(string s, size_t start)
{
    string digits;

    foreach (ch; s[start .. $])
    {
        if (ch >= '0' && ch <= '9')
            digits ~= ch;
        else
            break;
    }

    if (digits.length != 0)
        return to!int(digits);

    return 0;
}

/// ADOPT‑pure compare: return -1, 0, +1
int compareBasename(string a, string b)
{
    dbg(1, "compare: " ~ a ~ " vs " ~ b);

    auto pa = a.split("_");
    auto pb = b.split("_");

    //
    // CHAPTER: cNN or cNN-XX
    //
    int chA = (pa.length > 0 && pa[0].length >= 2)
        ? parseLeadingInt(pa[0], 1)
        : 0;

    int chB = (pb.length > 0 && pb[0].length >= 2)
        ? parseLeadingInt(pb[0], 1)
        : 0;

    dbg(2, "chapter: " ~ to!string(chA) ~ " vs " ~ to!string(chB));

    if (chA < chB) return -1;
    if (chA != chB) return 1;   // ADOPT‑pure: no '>'

    //
    // PAGE: pNNN
    //
    int pgA = (pa.length > 1 && pa[1].length >= 2)
        ? parseLeadingInt(pa[1], 1)
        : 0;

    int pgB = (pb.length > 1 && pb[1].length >= 2)
        ? parseLeadingInt(pb[1], 1)
        : 0;

    dbg(2, "page: " ~ to!string(pgA) ~ " vs " ~ to!string(pgB));

    if (pgA < pgB) return -1;
    if (pgA != pgB) return 1;

    //
    // SECTION: token 2
    //
    string secA = (pa.length > 2) ? pa[2] : "";
    string secB = (pb.length > 2) ? pb[2] : "";

    dbg(2, "section: " ~ secA ~ " vs " ~ secB);

    auto classA = classifySection(secA);
    auto classB = classifySection(secB);

    dbg(3, "section class: " ~ to!string(classA) ~ " / " ~ to!string(classB));

    if (classA < classB) return -1;
    if (classA != classB) return 1;

    //
    // same class: lexicographic
    //
    if (secA < secB) return -1;
    if (secA != secB) return 1;

    //
    // fallback: full string compare
    //
    dbg(3, "fallback alpha: " ~ a ~ " <=> " ~ b);

    if (a < b) return -1;
    if (a != b) return 1;

    return 0;
}

// End of Document /<repo:codepid/src/comparator.d/>

