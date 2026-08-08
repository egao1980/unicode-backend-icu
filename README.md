# unicode-backend-icu

[`unicode-protocol`](https://github.com/egao1980/unicode-protocol) backend over **ICU4C** via [`cl-stack-icu`](https://github.com/egao1980/cl-stack-icu).

## Capabilities (wave-1)

`:properties` `:normalize` `:nfkc-casefold` `:casefold` `:idna` `:script` `:emoji`

Deferred: `:char-name` / `:breaks` / `:uset` (need more CFFI surface).

```lisp
(asdf:load-system "unicode-backend-icu")  ; installs *unicode-backend*
(normalize "café" :form :nfc)
(idna-name-to-ascii "bücher.de")
```

## License

MIT
