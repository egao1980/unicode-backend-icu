;;;; Phase 1: install SUT dependency closure via cl-repository-client.
;;;; Deps from ghcr.io/egao1980/cl-systems (OCI). QL only for unpublished.

(setf asdf:*compile-file-failure-behaviour* :warn)

#+sbcl
(setf *debugger-hook*
      (lambda (c h)
        (declare (ignore h))
        (when (typep c 'sb-ext:defconstant-uneql)
          (invoke-restart 'continue))
        (format *error-output* "~&UNHANDLED: ~A~%" c)
        (uiop:quit 1)))
#-sbcl
(setf *debugger-hook*
      (lambda (c h)
        (declare (ignore h))
        (format *error-output* "~&UNHANDLED: ~A~%" c)
        (uiop:quit 1)))

(defun call-with-ci-muffles (fn)
  #+sbcl
  (handler-bind ((sb-ext:defconstant-uneql #'continue))
    (funcall fn))
  #-sbcl
  (funcall fn))

;;; Load client FIRST — separate top-level form so later `cl-repo:` reads resolve.
(call-with-ci-muffles (lambda () (asdf:load-system "cl-repository-client")))

(cl-repo:add-registry "https://ghcr.io" :namespace "egao1980/cl-systems" :priority :prepend)

(call-with-ci-muffles
 (lambda ()
   ;; babel/cffi/rove come from cl-systems OCI (cl-stack-systems imports).
   ;; Client bootstrap still QL-loads babel for the client only; muffling covers
   ;; defconstant-uneql if ASDF later compiles the OCI babel tree.
   (cl-repo:ensure-system-dependencies "unicode-backend-icu"
     :also-tests t)))

(format t "~&; ci: install phase done~%")
(uiop:quit 0)
