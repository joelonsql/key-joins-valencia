# Key Joins — PGConf.EU Valencia 2026

Andreas Karlsson and Joel Jacobson · 20 October 2026

Session: [Designing a new SQL language feature: Key joins][session].

[session]: https://www.postgresql.eu/events/pgconfeu2026/schedule/session/8343-designing-a-new-sql-language-feature-key-joins/

## Build

Install [Tectonic](https://tectonic-typesetting.github.io/), then run:

```sh
make
```

The PDF is written beside `key-joins-valencia-presentation.tex`. Intermediate
files and compiler logs go into `build/`. The first build may download LaTeX
packages; later builds use Tectonic's cache. No separate TeX installation is
required.

```sh
make examples   # Build the two standalone LaTeX examples
make clean      # Remove generated PDFs and build intermediates
```

For an offline build after the packages have been cached:

```sh
make TECTONIC_FLAGS='--untrusted --reruns 1 --keep-logs --only-cached'
```

The compiler can be selected with `make TECTONIC=/path/to/tectonic`.

## Files

- `key-joins-valencia-presentation.tex`: current deck, including presenter notes
  and source references in comments beside each slide.
- `assets/key-joins-valencia/`: photographs and the vector Mimer logo. All paths
  in the presentation are relative to the repository root.
- `examples/`: the interactive guarantees HTML and the standalone fanout and
  guarantees LaTeX examples. Open `key-joins-guarantees.html` directly in a browser;
  it needs no server or external assets.
- `notes/key-joins-valencia-transkription-rensad.txt`: the cleaned planning
  transcript, organized under the earlier presentation headings.
- `archive/`: earlier balanced and self-contained decks and Markdown presenter
  guides. These guides use older slide titles and numbering; the comments in
  the current `.tex` are the current presenter notes.

Generated PDFs and build intermediates are ignored by Git. The vector logo PDF
is a source asset and is not ignored. Earlier reference PDFs remain in `archive/`
on this machine, but are also ignored. `archive/examples/` preserves the two
older example PDFs found during migration; `make examples` builds their current
source versions under `examples/`.

The deck uses external assets, so build it with `make`. A LaTeX editor that only
accepts a single standalone source file cannot compile this project directly.
