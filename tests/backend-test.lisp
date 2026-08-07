(in-package #:unicode-backend-icu/tests)

(deftest system-loads
  (ok (asdf:find-system "unicode-backend-icu")))

(deftest use-icu-backend-installs
  (let ((backend (use-icu-backend)))
    (ok (typep backend 'icu-backend))
    (ok (eq *unicode-backend* backend))
    (ok (null (backend-capabilities backend)))))
