(in-package #:unicode-backend-icu)

(defmethod backend-normalize ((backend icu-backend) string form)
  (declare (ignore backend))
  (call-with-uchars
   string
   (lambda (src src-len)
     (cffi:with-foreign-object (err :int)
       (setf (cffi:mem-ref err :int) (%zero-error))
       (let ((norm (%normalize-instance form err)))
         (cl-stack-icu:check-icu (cffi:mem-ref err :int) "unorm2-get-instance")
         (setf (cffi:mem-ref err :int) (%zero-error))
         (let ((n (cl-stack-icu:unorm2-normalize norm src src-len
                                                 (cffi:null-pointer) 0 err)))
           (setf (cffi:mem-ref err :int) (%zero-error))
           (cffi:with-foreign-pointer (dest (* (cffi:foreign-type-size 'cl-stack-icu:u-char)
                                              (1+ (max n 0))))
             (setf n (cl-stack-icu:unorm2-normalize norm src src-len dest (1+ n) err))
             (cl-stack-icu:check-icu (cffi:mem-ref err :int) "unorm2-normalize")
             (cl-stack-icu:u-chars-to-lisp dest n))))))))

(defmethod backend-normalized-p ((backend icu-backend) string form)
  (string= string (backend-normalize backend string form)))

(defmethod backend-quick-check ((backend icu-backend) string form)
  (if (backend-normalized-p backend string form) :yes :no))

(defmethod backend-normalization-boundary-before-p ((backend icu-backend) code-point form)
  (declare (ignore backend code-point form))
  nil)

(defmethod backend-normalization-boundary-after-p ((backend icu-backend) code-point form)
  (declare (ignore backend code-point form))
  nil)

(defmethod backend-raw-decomposition ((backend icu-backend) code-point form)
  (declare (ignore backend code-point form))
  nil)
