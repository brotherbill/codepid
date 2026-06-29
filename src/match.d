// Start of Document /<repo:codepid/src/match.d/>

module match;

import std.file   : dirEntries, SpanMode;
import std.path   : baseName;
import std.string : toLower, stripLeft, indexOf;

/// ASCII helpers
private bool isDigit(char c)
{
    return ('0' <= c && c <= '9');
}

private bool isAlpha(char c)
{
    return (('A' <= c && c <= 'Z') ||
            ('a' <= c && c <= 'z'));
}

/// manual string→int
private int toInt(string s)
{
    int v = 0;
    size_t i = 0;

    while (i < s.length && isDigit(s[i]))
    {
        v = v * 10 + (s[i] - '0');
        i = i + 1;
    }

    return v;
}

/// manual underscore split
private string[] splitUnderscore(string s)
{
    string[] acc;
    size_t i = 0;
    size_t start = 0;

    while (i < s.length)
    {
        if (s[i] == '_')
        {
            acc ~= s[start .. i];
            start = i + 1;
        }
        i = i + 1;
    }

    acc ~= s[start .. s.length];
    return acc;
}

/// parse Prax filename: cNN_pNN_section_title
struct FileParts
{
    int chapter;
    int page;
    string section;
    string title;
}

private FileParts parseFile(string base)
{
    auto parts = splitUnderscore(base);

    FileParts fp;

    // chapter
    if (!(parts.length < 1))
    {
        auto p0 = parts[0];
        if (!(p0.length < 2) && p0[0] == 'c')
        {
            fp.chapter = toInt(p0[1 .. p0.length]);
        }
    }

    // page
    if (!(parts.length < 2))
    {
        auto p1 = parts[1];
        if (!(p1.length < 2) && p1[0] == 'p')
        {
            fp.page = toInt(p1[1 .. p1.length]);
        }
    }

    // section
    if (!(parts.length < 3))
    {
        fp.section = parts[2];
    }

    // title
    if (!(parts.length < 4))
    {
        string t;
        size_t i = 3;
        while (i < parts.length)
        {
            if (!(i == 3)) t ~= " ";
            t ~= parts[i];
            i = i + 1;
        }
        fp.title = t;
    }

    return fp;
}

/// parse token: cNN, cNNpNN, cNNa, cNNpNNa, with optional dots
struct TokenParts
{
    int chapter;
    int page;
    string section;
}

private TokenParts parseToken(string raw)
{
    TokenParts tp;

    // remove dots
    string s;
    size_t i = 0;
    while (i < raw.length)
    {
        if (raw[i] != '.')
            s ~= raw[i];
        i = i + 1;
    }

    // must start with c
    if (s.length == 0 || s[0] != 'c')
        return tp;

    // parse chapter digits
    size_t p = 1;
    string chapDigits;

    while (p < s.length && isDigit(s[p]))
    {
        chapDigits ~= s[p];
        p = p + 1;
    }

    tp.chapter = toInt(chapDigits);

    // parse optional page: pNN
    if (p < s.length && s[p] == 'p')
    {
        p = p + 1;
        string pageDigits;

        while (p < s.length && isDigit(s[p]))
        {
            pageDigits ~= s[p];
            p = p + 1;
        }

        tp.page = toInt(pageDigits);
    }

    // parse optional section: letters + digits
    if (p < s.length)
    {
        string sec;

        while (p < s.length)
        {
            sec ~= s[p];
            p = p + 1;
        }

        tp.section = sec;
    }

    return tp;
}

/// match file against token
private bool fileMatches(const FileParts fp, const TokenParts tp)
{
    // chapter must match
    if (fp.chapter < tp.chapter || tp.chapter < fp.chapter)
        return false;

    // page must match if token has page
    if (!(tp.page == 0))
    {
        if (fp.page < tp.page || tp.page < fp.page)
            return false;
    }

    // section must match if token has section
    if (!(tp.section.length == 0))
    {
        if (fp.section < tp.section || tp.section < fp.section)
            return false;
    }

    return true;
}

/// findMatches — return sorted basenames matching token
string[] findMatches(string folder, string token)
{
    auto tp = parseToken(token);

    string[] acc;

    foreach (entry; dirEntries(folder, SpanMode.shallow))
    {
        if (!entry.isFile) continue;

        auto base = baseName(entry.name);
        auto fp = parseFile(base);

        if (fileMatches(fp, tp))
            acc ~= base;
    }

    // simple lexicographic sort (no > or >=)
    size_t n = acc.length;
    size_t i = 0;
    while (i < n)
    {
        size_t j = i + 1;
        while (j < n)
        {
            if (acc[j] < acc[i])
            {
                auto tmp = acc[i];
                acc[i] = acc[j];
                acc[j] = tmp;
            }
            j = j + 1;
        }
        i = i + 1;
    }

    return acc;
}

// End of Document /<repo:codepid/src/match.d/>

