# unicode-backend-icu

[`unicode-protocol`](https://github.com/egao1980/unicode-protocol) backend over **ICU4C** via [`cl-stack-icu`](https://github.com/egao1980/cl-stack-icu).

## Capabilities

`:properties` `:normalize` `:nfkc-casefold` `:casefold` `:idna` `:script` `:emoji`
`:char-name` `:breaks` `:uset`

```lisp
(asdf:load-system "unicode-backend-icu")  ; installs *unicode-backend*
(normalize "café" :form :nfc)
(unicode-name #\A)                        ; "LATIN CAPITAL LETTER A"
(idna-name-to-ascii "bücher.de")
(make-unicode-set :pattern "[:Letter:]")
(make-break-iterator :grapheme)
```

## License

MIT
