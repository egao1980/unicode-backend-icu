(defpackage #:unicode-backend-icu
  (:use #:cl #:cffi #:unicode-protocol)
  (:local-nicknames (#:tg #:trivial-garbage))
  (:export #:icu-backend
           #:use-icu-backend
           #:*icu-backend*))

(in-package #:unicode-backend-icu)
