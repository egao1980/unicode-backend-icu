# unicode-backend-icu

[`unicode-protocol`](https://github.com/egao1980/unicode-protocol) backend over **ICU4C** (planned).

**Not for consumers yet.** This checkout is a scaffold only: CFFI bindings and ICU4C native overlays are **TODO**.

## Planned shape

| Piece | Role |
|-------|------|
| `unicode-backend-icu` | CLOS backend class + `use-icu-backend` |
| ICU4C overlays | Platform `libicuuc` / `libicui18n` / `libicuio` via [cl-repository](https://github.com/egao1980/cl-repository) (`linux` / `darwin` / `windows`) |
| grovel-at-build | CFFI definitions generated at build time against overlay headers |

Protocol `backend-*` generic functions are intentionally unimplemented here; callers get `no-applicable-method` until bindings land. Capability checks use `unicode-unsupported` once methods exist.

Tracks [cl-stack#151](https://github.com/egao1980/cl-stack/issues/151).

```lisp
(asdf:load-system "unicode-backend-icu")
(unicode-backend-icu:use-icu-backend)
```

## License

MIT
