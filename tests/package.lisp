(defpackage #:unicode-backend-icu/tests
  (:use #:cl #:rove #:unicode-protocol #:unicode-backend-icu))

(in-package #:unicode-backend-icu/tests)

(defun %s (&rest cps)
  "Build a string from Unicode scalar values."
  (map 'string #'code-char cps))
