// Start of Document /<repo:codepid/src/settings.d/>

module settings;

import std.string : strip;

/// fully immutable string alias
alias istring = immutable(char)[];

/// Root directory where sandbox projects are created.
/// Example:
///     /home/bb/dev/codepid/sandbox
enum istring SANDBOX_ROOT = "/home/bb/dev/codepid/sandbox";

/// Output executable name inside each sandbox project.
/// VS Code launch.json expects this exact filename.
enum istring OUTPUT_EXE_PATH = "app";

/// VS Code executable path.
/// On Linux this is normally just "code".
enum istring VSCODE_EXE = "code";

/// Notes:
/// - settings.d is the *living* configuration file.
/// - settings.json is deprecated and no longer used.
/// - All modules import settings.d directly.
/// - All paths are deterministic and operator‑grade.
/// - No environment variables, no indirection, no drift.

// End of Document /<repo:codepid/src/settings.d/>

