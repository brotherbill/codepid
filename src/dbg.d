// Start of Document /<repo:codepid/src/dbg.d/>

module dbg;

import std.stdio : writeln;

int DEBUG_LEVEL = 0;   // runtime-settable

void dbg(int level, string msg)
{
    if (level <= DEBUG_LEVEL)
        writeln(msg);
}

// End of Document /<repo:codepid/src/dbg.d/>

