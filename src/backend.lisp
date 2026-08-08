(in-package #:unicode-backend-icu)

(defclass icu-backend (unicode-backend) ()
  (:documentation "unicode-protocol backend over cl-stack-icu (ICU4C)."))

(defvar *icu-backend* nil)

(defmethod backend-capabilities ((backend icu-backend))
  '(:properties :normalize :nfkc-casefold :casefold :idna :script :emoji))

(defun use-icu-backend (&optional (backend (or *icu-backend*
                                              (setf *icu-backend*
                                                    (make-instance 'icu-backend)))))
  "Install ICU backend as *UNICODE-BACKEND*. Returns BACKEND."
  (use-unicode-backend backend)
  backend)

;;; Install on load (same DX as unicode-backend-cl-unicode).
(use-icu-backend)
