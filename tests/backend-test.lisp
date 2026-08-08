(in-package #:unicode-backend-icu/tests)

(deftest backend-installed
  (ok (typep *unicode-backend* 'icu-backend))
  (ok (member :idna (backend-capabilities *unicode-backend*)))
  (ok (member :normalize (backend-capabilities *unicode-backend*))))

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
