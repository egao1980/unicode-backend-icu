;;;; Smoke + capability registry.

(in-package #:unicode-backend-icu/tests)

(deftest backend-installed
  (ok (typep *unicode-backend* 'icu-backend))
  (dolist (cap '(:properties :normalize :nfkc-casefold :casefold :idna
                 :script :emoji :char-name :breaks :uset))
    (ok (member cap (backend-capabilities *unicode-backend*))
        (format nil "capability ~s" cap))))
