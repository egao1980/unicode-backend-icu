(defpackage #:unicode-backend-icu
  (:use #:cl #:unicode-protocol)
  (:export #:icu-backend
           #:use-icu-backend
           #:*icu-backend*))

(in-package #:unicode-backend-icu)
