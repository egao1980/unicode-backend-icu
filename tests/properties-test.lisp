;;;; Character properties — themes from ICU uchar / Python unicodedata / PyICU.

(in-package #:unicode-backend-icu/tests)

(deftest general-category-ascii
  (ok (eq (general-category #\A) :lu))
  (ok (eq (general-category #\a) :ll))
  (ok (eq (general-category #\1) :nd))
  (ok (eq (general-category #\Space) :zs))
  (ok (eq (general-category #\!) :po)))

(deftest binary-and-predicate-matrix
  (ok (alphabetic-p #\A))
  (ok (not (alphabetic-p #\1)))
  (ok (uppercase-p #\A))
  (ok (lowercase-p #\a))
  (ok (digit-p #\7))
  (ok (hex-digit-p #\F))
  (ok (whitespace-p #\Space))
  (ok (whitespace-p (code-char #x00A0))) ; NBSP
  (ok (letter-p #\Z))
  (ok (letter-or-digit-p #\9))
  (ok (identifier-start-p #\A))
  (ok (not (identifier-start-p #\1)))
  (ok (identifier-part-p #\1)))

(deftest emoji-and-pictographic
  (ok (emoji-p (code-char #x1F600)))          ; 😀
  (ok (extended-pictographic-p (code-char #x1F600)))
  (ok (not (emoji-p #\A))))

(deftest numeric-digit-mirror
  (ok (= (numeric-value #\5) 5d0))
  (ok (= (numeric-value (code-char #x00BD)) 0.5d0)) ; ½
  (ok (= (digit-value #\9) 9))
  (ok (null (digit-value #\A :radix 10)))
  (ok (= (digit-value #\A :radix 16) 10))
  (ok (mirrored-p #\())
  (ok (= (mirror-char #\() (char-code #\))))
  (ok (= (mirror-char #\A) (char-code #\A))))

(deftest age-and-names
  (ok (equal (age #\A) '(1 1 0 0)))
  (ok (search "LATIN CAPITAL LETTER A" (unicode-name #\A)))
  (ok (= (lookup-name "LATIN CAPITAL LETTER A") #x0041))
  (ok (search "HIRAGANA LETTER A" (unicode-name (code-char #x3042))))
  (ok (null (lookup-name "NOT A REAL UNICODE NAME XYZ"))))

(deftest script-keywords
  ;; Long PropertyValueAliases → keywords (:latin, :cyrillic, …)
  (ok (eq (script #\A) :latin))
  (ok (eq (script (code-char #x0410)) :cyrillic)) ; А
  (ok (member :latin (script-extensions #\A)))
  ;; U+30FC has Script_Extensions {Hira, Kana}
  (let ((ext (script-extensions (code-char #x30FC))))
    (ok (member :hiragana ext))
    (ok (member :katakana ext))))
