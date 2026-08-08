(in-package #:unicode-backend-icu)

;;; BreakIterator — raw holds (:bi pointer :buf pointer). Text buffer must outlive set-text.

(defun %break-kind (kind)
  (cffi:foreign-enum-value 'cl-stack-icu:u-break-iterator-type
                           (ecase kind
                             (:grapheme :character)
                             (:word :word)
                             (:line :line)
                             (:sentence :sentence))))

(defun %break-bi (iterator)
  (getf (break-raw iterator) :bi))

(defun %break-free-buf (iterator)
  (let ((buf (getf (break-raw iterator) :buf)))
    (when (and buf (not (cffi:null-pointer-p buf)))
      (cffi:foreign-free buf)
      (setf (getf (break-raw iterator) :buf) nil))))

(defmethod backend-make-break-iterator ((backend icu-backend) kind &key locale)
  (declare (ignore backend))
  (cffi:with-foreign-object (err :int)
    (setf (cffi:mem-ref err :int) (%zero-error))
    (let* ((loc (if (and locale (stringp locale)) locale ""))
           (bi (cl-stack-icu:ubrk-open (%break-kind kind) loc
                                       (cffi:null-pointer) 0 err)))
      (cl-stack-icu:check-icu (cffi:mem-ref err :int) "ubrk-open")
      (let ((it (make-instance 'break-iterator
                               :kind kind
                               :raw (list :bi bi :buf nil))))
        (tg:finalize it (lambda ()
                          (ignore-errors (cl-stack-icu:ubrk-close bi))))
        it))))

(defmethod backend-break-set-text ((backend icu-backend) iterator text)
  (declare (ignore backend))
  (%break-free-buf iterator)
  (cffi:with-foreign-string (utf8 (string text) :encoding :utf-8)
    (cffi:with-foreign-objects ((err :int) (needed :int32))
      (setf (cffi:mem-ref err :int) (%zero-error))
      (cl-stack-icu:u-str-from-utf8 (cffi:null-pointer) 0 needed utf8 -1 err)
      (let* ((n (cffi:mem-ref needed :int32))
             (buf (cffi:foreign-alloc 'cl-stack-icu:u-char :count (1+ (max n 0)))))
        (setf (cffi:mem-ref err :int) (%zero-error))
        (cl-stack-icu:u-str-from-utf8 buf (1+ n) needed utf8 -1 err)
        (cl-stack-icu:check-icu (cffi:mem-ref err :int) "u-str-from-utf8")
        (setf (getf (break-raw iterator) :buf) buf)
        (setf (cffi:mem-ref err :int) (%zero-error))
        (cl-stack-icu:ubrk-set-text (%break-bi iterator) buf
                                    (cffi:mem-ref needed :int32) err)
        (cl-stack-icu:check-icu (cffi:mem-ref err :int) "ubrk-set-text"))))
  iterator)

(defmethod backend-break-first ((backend icu-backend) iterator)
  (declare (ignore backend))
  (cl-stack-icu:ubrk-first (%break-bi iterator)))

(defmethod backend-break-last ((backend icu-backend) iterator)
  (declare (ignore backend))
  (cl-stack-icu:ubrk-last (%break-bi iterator)))

(defmethod backend-break-next ((backend icu-backend) iterator)
  (declare (ignore backend))
  (let ((n (cl-stack-icu:ubrk-next (%break-bi iterator))))
    (if (minusp n) nil n)))

(defmethod backend-break-previous ((backend icu-backend) iterator)
  (declare (ignore backend))
  (let ((n (cl-stack-icu:ubrk-previous (%break-bi iterator))))
    (if (minusp n) nil n)))

(defmethod backend-break-current ((backend icu-backend) iterator)
  (declare (ignore backend))
  (cl-stack-icu:ubrk-current (%break-bi iterator)))

(defmethod backend-break-following ((backend icu-backend) iterator offset)
  (declare (ignore backend))
  (let ((n (cl-stack-icu:ubrk-following (%break-bi iterator) offset)))
    (if (minusp n) nil n)))

(defmethod backend-break-preceding ((backend icu-backend) iterator offset)
  (declare (ignore backend))
  (let ((n (cl-stack-icu:ubrk-preceding (%break-bi iterator) offset)))
    (if (minusp n) nil n)))

(defmethod backend-break-is-boundary-p ((backend icu-backend) iterator offset)
  (declare (ignore backend))
  (plusp (cl-stack-icu:ubrk-is-boundary (%break-bi iterator) offset)))
