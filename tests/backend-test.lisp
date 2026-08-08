(in-package #:unicode-backend-icu/tests)

(deftest backend-installed
  (ok (typep *unicode-backend* 'icu-backend))
  (ok (member :idna (backend-capabilities *unicode-backend*)))
  (ok (member :normalize (backend-capabilities *unicode-backend*)))
  (ok (member :char-name (backend-capabilities *unicode-backend*)))
  (ok (member :breaks (backend-capabilities *unicode-backend*)))
  (ok (member :uset (backend-capabilities *unicode-backend*))))

(deftest general-category-and-normalize
  (ok (eq (general-category #\A) :lu))
  (ok (eq (general-category #\a) :ll))
  (ok (string= (normalize (map 'string #'code-char '(#x65 #x301)) :form :nfc)
               (string (code-char #x00E9)))))

(deftest casefold-eszett
  (ok (string= (casefold "ß") "ss")))

(deftest simple-case
  (ok (= (simple-downcase #\A) (char-code #\a)))
  (ok (= (simple-upcase #\a) (char-code #\A))))

(deftest idna-buecher
  (ok (string= (idna-name-to-ascii "bücher.de") "xn--bcher-kva.de"))
  (ok (string= (idna-name-to-unicode "xn--bcher-kva.de") "bücher.de")))

(deftest binary-props
  (ok (alphabetic-p #\A))
  (ok (not (alphabetic-p #\1)))
  (ok (emoji-p (code-char #x1F600))))

(deftest char-name-a
  (ok (search "LATIN CAPITAL LETTER A" (unicode-name #\A)))
  (ok (= (lookup-name "LATIN CAPITAL LETTER A") #x0041)))

(deftest numeric-and-age
  (ok (= (numeric-value #\5) 5d0))
  (ok (equal (age #\A) '(1 1 0 0))))

(deftest uset-letter
  (let ((s (make-unicode-set :pattern "[:Letter:]")))
    (ok (uset-contains-p s #\A))
    (ok (not (uset-contains-p s #\0)))
    (ok (plusp (uset-size s)))))

(deftest break-grapheme-ab
  (let ((it (make-break-iterator :grapheme)))
    (break-set-text it "ab")
    (ok (= (break-first it) 0))
    (ok (= (break-next it) 1))
    (ok (break-is-boundary-p it 1))))

(deftest quick-check-nfc
  (ok (eq (quick-check "a" :form :nfc) :yes)))
