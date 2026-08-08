;;;; Normalization — ICU Normalizer2 / Python unicodedata.normalize themes.

(in-package #:unicode-backend-icu/tests)

(deftest nfc-composition
  (let* ((decomp (%s #x65 #x301))
         (comp (string (code-char #x00E9))))
    (ok (string= (normalize decomp :form :nfc) comp))
    (ok (normalized-p comp :form :nfc))
    (ok (not (normalized-p decomp :form :nfc)))))

(deftest nfd-decomposition
  (let ((comp (string (code-char #x00E9))))
    (ok (string= (normalize comp :form :nfd) (%s #x65 #x301)))
    (ok (eq (quick-check (%s #x65 #x301) :form :nfd) :yes))))

(deftest nfkc-compatibility-ligature
  ;; ﬁ (U+FB01) → "fi" under NFKC
  (ok (string= (normalize (string (code-char #xFB01)) :form :nfkc) "fi")))

(deftest nfkc-casefold-eszett
  (ok (string= (normalize "ß" :form :nfkc-casefold) "ss"))
  (ok (string= (normalize "Straße" :form :nfkc-casefold) "strasse")))

(deftest normalize-idempotent
  (dolist (form '(:nfc :nfd :nfkc :nfkd))
    (let* ((s "Café résumé")
           (n (normalize s :form form)))
      (ok (string= n (normalize n :form form))
          (format nil "idempotent ~s" form)))))

(deftest quick-check-yes
  (ok (eq (quick-check "a" :form :nfc) :yes))
  (ok (member (quick-check (%s #x65 #x301) :form :nfc) '(:no :maybe))))

(deftest raw-decomposition-a-acute
  (let ((d (raw-decomposition (code-char #x00E9) :form :nfd)))
    (ok (stringp d))
    (ok (= (length d) 2))))
