(defsystem "unicode-backend-icu"
  :version "0.1.0"
  :description "unicode-protocol backend over ICU4C (scaffold — bindings TODO)"
  :author "egao1980"
  :license "MIT"
  :depends-on ("unicode-protocol" "cffi")
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "backend"))
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
