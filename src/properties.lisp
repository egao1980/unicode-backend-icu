(in-package #:unicode-backend-icu)

(defun %property-int (property)
  (cffi:foreign-enum-value 'cl-stack-icu:u-property (%property-enum property)))

(defun %name-choice (choice)
  (cffi:foreign-enum-value 'cl-stack-icu:u-char-name-choice
                           (ecase (or choice :unicode)
                             (:unicode :unicode)
                             (:extended :extended)
                             (:alias :alias))))

(defun %prop-name-choice (short)
  (cffi:foreign-enum-value 'cl-stack-icu:u-property-name-choice
                           (if short :short :long)))

(defun %icu-name→keyword (name)
  (when (and name (plusp (length name)))
    (intern (string-upcase (substitute #\- #\_ name :test #'char=)) :keyword)))

(defun %property-value-keyword (property value)
  (let ((s (cl-stack-icu:u-get-property-value-name
            (%property-int property) value (%prop-name-choice nil))))
    (or (%icu-name→keyword s) value)))

(defmethod backend-binary-property-p ((backend icu-backend) code-point property)
  (declare (ignore backend))
  (plusp (cl-stack-icu:u-has-binary-property code-point (%property-int property))))

(defmethod backend-int-property ((backend icu-backend) code-point property)
  (declare (ignore backend))
  (let* ((prop (%property-enum property))
         (v (cl-stack-icu:u-get-int-property-value code-point (%property-int prop))))
    (case prop
      (:general-category
       (or (%gc-keyword (cl-stack-icu:u-char-type code-point))
           (%gc-keyword v)))
      ((:canonical-combining-class) v)
      ((:script :block :bidi-class :east-asian-width)
       (%property-value-keyword prop v))
      (otherwise v))))

(defmethod backend-script-extensions ((backend icu-backend) code-point)
  (declare (ignore backend))
  (cffi:with-foreign-objects ((err :int) (scripts :int32 16))
    (setf (cffi:mem-ref err :int) (%zero-error))
    (let ((n (cl-stack-icu:uscript-get-script-extensions code-point scripts 16 err)))
      (when (= (cffi:mem-ref err :int)
               (cffi:foreign-enum-value 'cl-stack-icu:u-error-code :buffer-overflow-error))
        (setf (cffi:mem-ref err :int) (%zero-error))
        (cffi:with-foreign-object (scripts2 :int32 (max n 1))
          (setf n (cl-stack-icu:uscript-get-script-extensions code-point scripts2 n err))
          (cl-stack-icu:check-icu (cffi:mem-ref err :int) "uscript-get-script-extensions")
          (return-from backend-script-extensions
            (loop for i below n
                  collect (%property-value-keyword :script (cffi:mem-aref scripts2 :int32 i))))))
      (cl-stack-icu:check-icu (cffi:mem-ref err :int) "uscript-get-script-extensions")
      (loop for i below n
            collect (%property-value-keyword :script (cffi:mem-aref scripts :int32 i))))))

(defmethod backend-char-name ((backend icu-backend) code-point &key (choice :unicode))
  (declare (ignore backend))
  (cffi:with-foreign-object (err :int)
    (setf (cffi:mem-ref err :int) (%zero-error))
    (cffi:with-foreign-pointer (buf 256)
      (let ((n (cl-stack-icu:u-char-name code-point (%name-choice choice) buf 256 err)))
        (when (and (cl-stack-icu:u-success-p (cffi:mem-ref err :int)) (plusp n))
          (cffi:foreign-string-to-lisp buf :count n))))))

(defmethod backend-lookup-name ((backend icu-backend) name)
  (declare (ignore backend))
  (cffi:with-foreign-object (err :int)
    (setf (cffi:mem-ref err :int) (%zero-error))
    (let ((cp (cl-stack-icu:u-char-from-name
               (cffi:foreign-enum-value 'cl-stack-icu:u-char-name-choice :unicode)
               (string name) err)))
      (when (cl-stack-icu:u-success-p (cffi:mem-ref err :int))
        cp))))

(defmethod backend-numeric-value ((backend icu-backend) code-point)
  (declare (ignore backend))
  (let ((v (cl-stack-icu:u-get-numeric-value code-point)))
    (unless (= v cl-stack-icu:+u-no-numeric-value+)
      v)))

(defmethod backend-digit-value ((backend icu-backend) code-point &key (radix 10))
  (declare (ignore backend))
  (let ((v (cl-stack-icu:u-digit code-point radix)))
    (unless (minusp v) v)))

(defmethod backend-mirror-char ((backend icu-backend) code-point)
  (declare (ignore backend))
  (cl-stack-icu:u-char-mirror code-point))

(defmethod backend-age ((backend icu-backend) code-point)
  (declare (ignore backend))
  ;; UVersionInfo is uint8_t[4]
  (cffi:with-foreign-pointer (ver 4)
    (cl-stack-icu:u-char-age code-point ver)
    (list (cffi:mem-aref ver :uint8 0)
          (cffi:mem-aref ver :uint8 1)
          (cffi:mem-aref ver :uint8 2)
          (cffi:mem-aref ver :uint8 3))))

(defmethod backend-property-value-name ((backend icu-backend) property value &key short)
  (declare (ignore backend))
  (flet ((name-for (int)
           (cl-stack-icu:u-get-property-value-name
            (%property-int property) int (%prop-name-choice short))))
    (cond
      ((integerp value)
       (or (name-for value) (princ-to-string value)))
      ((and (keywordp value) (eq (%property-enum property) :general-category))
       (or (ignore-errors
             (name-for (cffi:foreign-enum-value 'cl-stack-icu:u-char-category value)))
           (string-downcase (symbol-name value))))
      ((keywordp value)
       (string-downcase (symbol-name value)))
      (t (princ-to-string value)))))
