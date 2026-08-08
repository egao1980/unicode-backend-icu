(defpackage #:unicode-backend-icu
  (:use #:cl #:cffi #:unicode-protocol)
  (:export #:icu-backend
           #:use-icu-backend
           #:*icu-backend*))

(in-package #:unicode-backend-icu)
