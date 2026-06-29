// Start of Document /<repo:codepid/src/section.d/>

module section;

import std.ascii : isAlpha, isDigit;

/// SectionClass — describes which union member is active
enum SectionClass {
    letterFirst,
    numberFirst
}

/// Letter-first section token: a, a1, a1b
struct LetterFirstSection {
    char  leadingLetter;     // always present
    ubyte numberPart;        // optional, 0 means absent
    char  trailingLetter;    // optional, '\0' means absent
}

/// Number-first section token: 3, 3a, 3a2
struct NumberFirstSection {
    ubyte leadingNumber;     // always present
    char  letterPart;        // optional, '\0' means absent
    ubyte trailingNumber;    // optional, 0 means absent
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

    // LETTER-FIRST: L [N] [L]
    if (isAlpha(s[0])) {
        info.classNumber = SectionClass.letterFirst;

        size_t i = 0;
        info.letterFirst.leadingLetter = s[i];
        i++;

        // optional numberPart
        while (i < s.length && isDigit(s[i])) {
            info.letterFirst.numberPart =
                cast(ubyte)(info.letterFirst.numberPart * 10 + (s[i] - '0'));
            i++;
        }

        // optional trailingLetter
        if (i < s.length && isAlpha(s[i])) {
            info.letterFirst.trailingLetter = s[i];
        } else {
            info.letterFirst.trailingLetter = '\0';
        }

        return info;
    }

    // NUMBER-FIRST: N [L] [N]
    if (isDigit(s[0])) {
        info.classNumber = SectionClass.numberFirst;

        size_t i = 0;

        // leadingNumber
        while (i < s.length && isDigit(s[i])) {
            info.numberFirst.leadingNumber =
                cast(ubyte)(info.numberFirst.leadingNumber * 10 + (s[i] - '0'));
            i++;
        }

        // optional letterPart
        if (i < s.length && isAlpha(s[i])) {
            info.numberFirst.letterPart = s[i];
            i++;
        } else {
            info.numberFirst.letterPart = '\0';
        }

        // optional trailingNumber
        while (i < s.length && isDigit(s[i])) {
            info.numberFirst.trailingNumber =
                cast(ubyte)(info.numberFirst.trailingNumber * 10 + (s[i] - '0'));
            i++;
        }

        return info;
    }

    // fallback: treat as number-first
    info.classNumber = SectionClass.numberFirst;
    return info;
}

// End of Document /<repo:codepid/src/section.d/>

