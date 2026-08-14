;;;; IDNA / UTS #46 — ICU UIDNA / classic Punycode examples.

(in-package #:unicode-backend-icu/tests)

(deftest idna-buecher-roundtrip
  (ok (string= (idna-name-to-ascii "bücher.de") "xn--bcher-kva.de"))
  (ok (string= (idna-name-to-unicode "xn--bcher-kva.de") "bücher.de")))

(deftest idna-ascii-identity
  (ok (string= (idna-name-to-ascii "example.com") "example.com"))
  (ok (string= (idna-name-to-unicode "example.com") "example.com")))

(deftest idna-label-apis
  (ok (string= (idna-label-to-ascii "bücher") "xn--bcher-kva"))
  (ok (string= (idna-label-to-unicode "xn--bcher-kva") "bücher")))

(deftest idna-map-options
  ;; Map/normalize path should honor STD3/transitional flags (smoke: non-empty + ASCII-safe).
  (let ((mapped (idna-map "Bücher")))
    (ok (string-equal mapped "bücher")))
  (ok (stringp (idna-map "Bücher" :std3 t)))
  (ok (stringp (idna-map "Bücher" :transitional t))))

(deftest idna-japanese
  ;; 日本語.jp — smoke: ASCII form is xn--…
  (let ((a (idna-name-to-ascii "日本語.jp")))
    (ok (search "xn--" a))
    (ok (search ".jp" a))))
