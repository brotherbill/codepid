// Start of Document /<repo:codepid/src/section.d/>

module section;

import std.ascii : isAlpha, isDigit;

/// SectionClass — describes which union member is active
enum SectionClass {
    letterFirst,
    numberFirst
}

/// Letter-first section token: a, a12, a12b
struct LetterFirstSection {
    char  leadingLetter;     // always present
    uint  numberPart;        // optional, 0 means absent
    char  trailingLetter;    // optional, '\0' means absent
}

/// Number-first section token: 3, 34a, 34a2
struct NumberFirstSection {
    uint  leadingNumber;     // always present
    char  letterPart;        // optional, '\0' means absent
    uint  trailingNumber;    // optional, 0 means absent
}

/// Unified variant wrapper using a D union
struct SectionInfo {
    SectionClass classNumber;

    union {
        LetterFirstSection letterFirst;
        NumberFirstSection numberFirst;
    }
}

/// classifySection — parse section token into union-based SectionInfo
SectionInfo classifySection(string s)
{
    SectionInfo info;

    if (s.length == 0) {
        info.classNumber = SectionClass.numberFirst;
        return info;
    }

    // LETTER-FIRST: L [NNN] [L]
    if (isAlpha(s[0])) {
        info.classNumber = SectionClass.letterFirst;

        size_t i = 0;
        info.letterFirst.leadingLetter = s[i];
        i = i + 1;

        // optional multi-digit numberPart
        uint num = 0;
        bool haveNum = false;
        while (i < s.length && isDigit(s[i])) {
            haveNum = true;
            num = num * 10 + cast(uint)(s[i] - '0');
            i = i + 1;
        }
        if (haveNum) {
            info.letterFirst.numberPart = num;
        } else {
            info.letterFirst.numberPart = 0;
        }

        // optional trailingLetter
        if (i < s.length && isAlpha(s[i])) {
            info.letterFirst.trailingLetter = s[i];
        } else {
            info.letterFirst.trailingLetter = '\0';
        }

        return info;
    }

    // NUMBER-FIRST: NNN [L] [NNN]
    if (isDigit(s[0])) {
        info.classNumber = SectionClass.numberFirst;

        size_t i = 0;

        // leadingNumber (multi-digit)
        uint lead = 0;
        while (i < s.length && isDigit(s[i])) {
            lead = lead * 10 + cast(uint)(s[i] - '0');
            i = i + 1;
        }
        info.numberFirst.leadingNumber = lead;

        // optional letterPart
        if (i < s.length && isAlpha(s[i])) {
            info.numberFirst.letterPart = s[i];
            i = i + 1;
        } else {
            info.numberFirst.letterPart = '\0';
        }

        // optional trailingNumber (multi-digit)
        uint tail = 0;
        bool haveTail = false;
        while (i < s.length && isDigit(s[i])) {
            haveTail = true;
            tail = tail * 10 + cast(uint)(s[i] - '0');
            i = i + 1;
        }
        if (haveTail) {
            info.numberFirst.trailingNumber = tail;
        } else {
            info.numberFirst.trailingNumber = 0;
        }

        return info;
    }

    // fallback: treat as number-first
    info.classNumber = SectionClass.numberFirst;
    return info;
}

// End of Document /<repo:codepid/src/section.d/>

