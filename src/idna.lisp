(in-package #:unicode-backend-icu)

;;; UTS #46 via ICU uidna_* (cl-stack-icu).

(cffi:defcstruct uidna-info
  (size :int16)
  (is-transitional-different :uint8)
  (reserved-b3 :uint8)
  (errors :uint32)
  (reserved-i2 :int32)
  (reserved-i3 :int32))

(defun %uidna-convert (name options direction)
  "DIRECTION is :name-ascii | :name-unicode | :label-ascii | :label-unicode."
  (let ((opts (%uidna-options options))
        (fn (ecase direction
              (:name-ascii #'cl-stack-icu:uidna-name-to-ascii)
              (:name-unicode #'cl-stack-icu:uidna-name-to-unicode)
              (:label-ascii #'cl-stack-icu:uidna-label-to-ascii)
              (:label-unicode #'cl-stack-icu:uidna-label-to-unicode))))
    (cffi:with-foreign-object (err :int)
      (setf (cffi:mem-ref err :int) (%zero-error))
      (let ((idna (cl-stack-icu:uidna-open-uts46 opts err)))
        (cl-stack-icu:check-icu (cffi:mem-ref err :int) "uidna-open-uts46")
        (unwind-protect
             (call-with-uchars
              name
              (lambda (src src-len)
                (cffi:with-foreign-object (info '(:struct uidna-info))
                  (setf (cffi:foreign-slot-value info '(:struct uidna-info) 'size)
                        (cffi:foreign-type-size '(:struct uidna-info)))
                  (setf (cffi:foreign-slot-value info '(:struct uidna-info)
                                                 'is-transitional-different)
                        0)
                  (setf (cffi:foreign-slot-value info '(:struct uidna-info) 'errors) 0)
                  (setf (cffi:mem-ref err :int) (%zero-error))
                  (let ((cap (max 64 (* src-len 4))))
                    (flet ((run (dest capacity)
                             (setf (cffi:foreign-slot-value info '(:struct uidna-info) 'errors) 0)
                             (setf (cffi:mem-ref err :int) (%zero-error))
                             (funcall fn idna src src-len dest capacity info err)))
                      (cffi:with-foreign-pointer
                          (dest (* (cffi:foreign-type-size 'cl-stack-icu:u-char) (1+ cap)))
                        (let ((n (run dest cap)))
                          (when (= (cffi:mem-ref err :int)
                                   (cffi:foreign-enum-value 'cl-stack-icu:u-error-code
                                                            :buffer-overflow-error))
                            (let ((need (1+ n)))
                              (cffi:with-foreign-pointer
                                  (dest2 (* (cffi:foreign-type-size 'cl-stack-icu:u-char) need))
                                (setf n (run dest2 need))
                                (handler-case
                                    (cl-stack-icu:check-icu (cffi:mem-ref err :int) "uidna")
                                  (cl-stack-icu:icu-error (c)
                                    (error 'unicode-idna-error
                                           :message (cl-stack-icu:icu-error-message c))))
                                (return-from %uidna-convert
                                  (cl-stack-icu:u-chars-to-lisp dest2 n)))))
                          (handler-case
                              (cl-stack-icu:check-icu (cffi:mem-ref err :int) "uidna")
                            (cl-stack-icu:icu-error (c)
                              (error 'unicode-idna-error
                                     :message (cl-stack-icu:icu-error-message c))))
                          (cl-stack-icu:u-chars-to-lisp dest n))))))))
          (cl-stack-icu:uidna-close idna))))))

(defmethod backend-idna-name-to-ascii ((backend icu-backend) name &key options)
  (declare (ignore backend))
  (%uidna-convert name options :name-ascii))

(defmethod backend-idna-name-to-unicode ((backend icu-backend) name &key options)
  (declare (ignore backend))
  (%uidna-convert name options :name-unicode))

(defmethod backend-idna-label-to-ascii ((backend icu-backend) label &key options)
  (declare (ignore backend))
  (%uidna-convert label options :label-ascii))

(defmethod backend-idna-label-to-unicode ((backend icu-backend) label &key options)
  (declare (ignore backend))
  (%uidna-convert label options :label-unicode))

(defmethod backend-idna-map ((backend icu-backend) string &key std3 transitional)
  "UTS #46 via ICU UIDNA (nameToUnicode applies map+normalize; honors STD3/transitional)."
  (let ((opts '()))
    (when std3 (push :std3 opts))
    (when transitional (push :transitional opts))
    (backend-idna-name-to-unicode backend string :options opts)))
