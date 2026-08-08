(in-package #:unicode-backend-icu)

;;; Root/default case via ICU code-point APIs + u_strTo* for full string case.
;;; Locale-aware case lives in l10n-backend-icu.

(defmethod backend-simple-casefold ((backend icu-backend) code-point)
  (declare (ignore backend))
  (cl-stack-icu:u-fold-case code-point cl-stack-icu:+u-fold-case-default+))

(defmethod backend-simple-downcase ((backend icu-backend) code-point)
  (declare (ignore backend))
  (cl-stack-icu:u-tolower code-point))

(defmethod backend-simple-upcase ((backend icu-backend) code-point)
  (declare (ignore backend))
  (cl-stack-icu:u-toupper code-point))

(defmethod backend-simple-titlecase ((backend icu-backend) code-point)
  (declare (ignore backend))
  ;; No single-code-point title API in our FFI; approximate with toupper for BMP letters.
  (cl-stack-icu:u-toupper code-point))

(defun %map-cps (string mapper)
  (with-output-to-string (out)
    (loop for c across (string string)
          do (write-char (code-char (funcall mapper (char-code c))) out))))

(defmethod backend-casefold ((backend icu-backend) string &key)
  ;; Full Unicode case fold (ß→ss). u_foldCase is simple/1:1; use NFKC_Casefold.
  (backend-normalize backend string :nfkc-casefold))

(defmethod backend-downcase ((backend icu-backend) string &key)
  (declare (ignore backend))
  (call-with-uchars
   string
   (lambda (src src-len)
     (cffi:with-foreign-object (err :int)
       (setf (cffi:mem-ref err :int) (%zero-error))
       (let ((n (cl-stack-icu:u-str-to-lower (cffi:null-pointer) 0 src src-len "" err)))
         (setf (cffi:mem-ref err :int) (%zero-error))
         (cffi:with-foreign-pointer (dest (* (cffi:foreign-type-size 'cl-stack-icu:u-char)
                                            (1+ (max n 0))))
           (setf n (cl-stack-icu:u-str-to-lower dest (1+ n) src src-len "" err))
           (cl-stack-icu:check-icu (cffi:mem-ref err :int) "u-str-to-lower")
           (cl-stack-icu:u-chars-to-lisp dest n)))))))

(defmethod backend-upcase ((backend icu-backend) string &key)
  (declare (ignore backend))
  (call-with-uchars
   string
   (lambda (src src-len)
     (cffi:with-foreign-objects ((err :int))
       (setf (cffi:mem-ref err :int) (%zero-error))
       (let ((n (cl-stack-icu:u-str-to-upper (cffi:null-pointer) 0 src src-len "" err)))
         (setf (cffi:mem-ref err :int) (%zero-error))
         (cffi:with-foreign-pointer (dest (* (cffi:foreign-type-size 'cl-stack-icu:u-char)
                                            (1+ (max n 0))))
           (setf n (cl-stack-icu:u-str-to-upper dest (1+ n) src src-len "" err))
           (cl-stack-icu:check-icu (cffi:mem-ref err :int) "u-str-to-upper")
           (cl-stack-icu:u-chars-to-lisp dest n)))))))

(defmethod backend-titlecase ((backend icu-backend) string &key)
  (declare (ignore backend))
  (call-with-uchars
   string
   (lambda (src src-len)
     (cffi:with-foreign-objects ((err :int))
       (setf (cffi:mem-ref err :int) (%zero-error))
       (let ((n (cl-stack-icu:u-str-to-title (cffi:null-pointer) 0 src src-len
                                             (cffi:null-pointer) "" err)))
         (setf (cffi:mem-ref err :int) (%zero-error))
         (cffi:with-foreign-pointer (dest (* (cffi:foreign-type-size 'cl-stack-icu:u-char)
                                            (1+ (max n 0))))
           (setf n (cl-stack-icu:u-str-to-title dest (1+ n) src src-len
                                                (cffi:null-pointer) "" err))
           (cl-stack-icu:check-icu (cffi:mem-ref err :int) "u-str-to-title")
           (cl-stack-icu:u-chars-to-lisp dest n)))))))
