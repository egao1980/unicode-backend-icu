(defsystem "unicode-backend-icu"
  :version "0.1.0"
  :description "unicode-protocol backend over cl-stack-icu (ICU4C)"
  :author "egao1980"
  :license "MIT"
  :depends-on ("unicode-protocol" "cl-stack-icu" "cffi" "trivial-garbage")
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "util")
               (:file "backend")
               (:file "properties")
               (:file "normalize")
               (:file "case")
               (:file "idna")
               (:file "break")
               (:file "uset"))
  :in-order-to ((test-op (test-op "unicode-backend-icu/tests"))))

(defsystem "unicode-backend-icu/tests"
  :depends-on ("unicode-backend-icu" "rove")
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "backend-test"))
  :perform (test-op (o c)
             (unless (symbol-call :rove :run c)
               (error "tests failed for ~A" (component-name c)))))
