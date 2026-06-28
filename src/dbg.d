// Start of Document /<repo:codepid/src/dbg.d/>

module dbg;

import std.stdio : writeln;

/// Local debug level for dbg() output.
/// 0 = silent
/// 1 = minimal tracing (recommended)
enum int DEBUG_LEVEL = 1;

/// Minimal debug output.
/// Prints only when level <= DEBUG_LEVEL.
void dbg(int level, lazy string msg)
{
    if (level <= DEBUG_LEVEL)
        writeln(msg);
}

// End of Document /<repo:codepid/src/dbg.d/>

