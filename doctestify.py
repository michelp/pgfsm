from pathlib import Path

def doctestify(test):
    '''Convert pg_revert output to markdown.

    Text line blocks that start with `--` are stripped of that prefix
    to turn them into markdown.  Line blocks that do not start with
    `--` are turned into markdown code blocks.  A line can be hidden
    by putting `-- pragma:hide` somewhere in it, this will omit it
    from the output and useful for hiding psql metacommands also
    supported by pg_revert.

    >>> print(doctestify("""
    ... -- # Header
    ... --
    ... -- This is a *paragraph*.
    ... \pset something -- pragma:hide
    ...
    ... select version();
    ...                                                  version
    ... ----------------------------------------------------------------------------------------------------------
    ...  PostgreSQL 18devel on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0, 64-bit
    ... (1 row)
    ...
    ... -- ## Subheader
    ... --
    ... -- - a list
    ... -- - _bold_
    ... select print('int32(4:4)'::matrix);
    ... ┌────────────────────┐
    ... │       print        │
    ... ├────────────────────┤
    ... │      0  1  2  3   ↵│
    ... │    ────────────   ↵│
    ... │  0│               ↵│
    ... │  1│               ↵│
    ... │  2│               ↵│
    ... │  3│               ↵│
    ... │                    │
    ... └────────────────────┘
    ... (1 row)
    ... """))
    # Header
    <BLANKLINE>
    This is a *paragraph*.
    ``` postgres-console
    select version();
                                                     version
    ----------------------------------------------------------------------------------------------------------
     PostgreSQL 18devel on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0, 64-bit
    (1 row)
    ```
    ## Subheader
    <BLANKLINE>
    - a list
    - _bold_
    ``` postgres-console
    select print('int32(4:4)'::matrix);
    ┌────────────────────┐
    │       print        │
    ├────────────────────┤
    │      0  1  2  3   ↵│
    │    ────────────   ↵│
    │  0│               ↵│
    │  1│               ↵│
    │  2│               ↵│
    │  3│               ↵│
    │                    │
    └────────────────────┘
    (1 row)
    ```
    '''
    lines = test.splitlines()
    markdown_lines = []
    code_block = False

    for line in lines:
        if not line or line.startswith("\\") or "-- pragma:hide" in line:
            continue

        line = line.replace("\\u", "&#x")
        if line.startswith("--") and not line.startswith("---"):
            if code_block:
                markdown_lines.append("```")
                code_block = False
            markdown_lines.append(line[3:])
        else:
            if not code_block:
                markdown_lines.append("``` postgres-console")
                code_block = True
            markdown_lines.append(line)

    if code_block:
        markdown_lines.append("```")

    return "\n".join(markdown_lines)

if __name__ == '__main__':
    import sys
    inpath = Path(sys.argv[1])
    infile = open(inpath, 'r')
    if len(sys.argv) == 3:
        outpath = Path(sys.argv[2])
    else:
        outpath = Path(*infile.with_suffix('.md'))
    outfile = open(outpath, 'w+')
    outfile.write(doctestify(infile.read()))
