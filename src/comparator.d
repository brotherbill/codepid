// Start of Document /<repo:codepid/src/comparator.d/>

module comparator;

import std.path : baseName;

/// ASCII digit helper
private bool isDigit(char c)
{
    return ('0' <= c && c <= '9');
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

/// section classification
/// 1 = letter-only (a, b, c)
/// 2 = number+letter (1a, 2b)
/// 3 = number-only (1, 2)
private int classifySection(string s)
{
    if (s.length == 0) return 3;

    size_t i = 0;

    // letter-only
    if (!isDigit(s[0]))
    {
        return 1;
    }

    // starts with digit
    i = 1;
    while (i < s.length && isDigit(s[i]))
    {
        i = i + 1;
    }

    // pure number
    if (i == s.length)
    {
        return 3;
    }

    // number+letter
    return 2;
}

/// extract numeric prefix from section
private int sectionNumber(string s)
{
    size_t i = 0;
    string digits;

    while (i < s.length && isDigit(s[i]))
    {
        digits ~= s[i];
        i = i + 1;
    }

    if (digits.length == 0) return 0;
    return toInt(digits);
}

/// extract suffix (letters after numeric prefix)
private string sectionSuffix(string s)
{
    size_t i = 0;

    while (i < s.length && isDigit(s[i]))
    {
        i = i + 1;
    }

    return s[i .. s.length];
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

/// lexicographic string compare using only < and <=
private bool strLess(string a, string b)
{
    size_t i = 0;

    while (i < a.length && i < b.length)
    {
        auto ca = a[i];
        auto cb = b[i];

        if (ca < cb) return true;
        if (cb < ca) return false;

        i = i + 1;
    }

    if (a.length < b.length) return true;
    return false;
}

/// Prax operator comparator
private bool fileLess(const FileParts a, const FileParts b)
{
    // chapter
    if (a.chapter < b.chapter) return true;
    if (b.chapter < a.chapter) return false;

    // page
    if (a.page < b.page) return true;
    if (b.page < a.page) return false;

    // section class
    auto ca = classifySection(a.section);
    auto cb = classifySection(b.section);

    if (ca < cb) return true;
    if (cb < ca) return false;

    // section numeric prefix
    auto na = sectionNumber(a.section);
    auto nb = sectionNumber(b.section);

    if (na < nb) return true;
    if (nb < na) return false;

    // section suffix
    auto sa = sectionSuffix(a.section);
    auto sb = sectionSuffix(b.section);

    if (strLess(sa, sb)) return true;
    if (strLess(sb, sa)) return false;

    // title
    if (strLess(a.title, b.title)) return true;

    return false;
}

/// compare two basenames cNN_pNN_section_title
bool basenameLess(string a, string b)
{
    auto fa = parseFile(baseName(a));
    auto fb = parseFile(baseName(b));

    return fileLess(fa, fb);
}

// End of Document /<repo:codepid/src/comparator.d/>

