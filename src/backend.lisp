(in-package #:unicode-backend-icu)

(defclass icu-backend (unicode-backend) ()
  (:documentation "unicode-protocol backend over ICU4C (scaffold — CFFI bindings TODO)."))

(defvar *icu-backend* nil)

(defmethod backend-capabilities ((backend icu-backend))
  ;; Planned: :properties :normalize :casefold :idna :breaks :uset …
  '())

(defun use-icu-backend (&optional (backend (or *icu-backend*
                                              (setf *icu-backend*
                                                    (make-instance 'icu-backend)))))
  "Install ICU backend as *UNICODE-BACKEND*. Returns BACKEND."
  (use-unicode-backend backend)
  backend)
