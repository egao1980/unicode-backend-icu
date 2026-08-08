;;;; UnicodeSet — ICU uset / pattern syntax themes.

(in-package #:unicode-backend-icu/tests)

(deftest uset-letter-pattern
  (let ((s (make-unicode-set :pattern "[:Letter:]")))
    (ok (uset-contains-p s #\A))
    (ok (not (uset-contains-p s #\0)))
    (ok (plusp (uset-size s)))
    (ok (not (uset-empty-p s)))))

(deftest uset-mutate-add-remove
  (let ((s (make-unicode-set)))
    (ok (uset-empty-p s))
    (uset-add s #\A)
    (ok (uset-contains-p s #\A))
    (uset-add s "fi")
    (ok (uset-contains-p s "fi"))
    (uset-remove s #\A)
    (ok (not (uset-contains-p s #\A)))
    (uset-clear s)
    (ok (uset-empty-p s))))

(deftest uset-span-digits
  (let ((s (make-unicode-set :pattern "[:Digit:]")))
    (ok (= (uset-span s "123abc") 3))
    (ok (zerop (uset-span s "abc123")))))

(deftest uset-property-pattern
  (let ((s (make-unicode-set :pattern "\\p{Script=Latin}")))
    (ok (uset-contains-p s #\Z))
    (ok (not (uset-contains-p s (code-char #x0410))))))
