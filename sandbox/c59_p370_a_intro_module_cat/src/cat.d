module cat; // may omit, but no need to

class Cat
{
    string name;

    this(string name)
    {
        import std.stdio : writeln;

        this.name = name;
        writeln("constructed Cat: ", name);
    }
}
