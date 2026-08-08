(in-package #:unicode-backend-icu)

(defmethod backend-binary-property-p ((backend icu-backend) code-point property)
  (declare (ignore backend))
  (plusp (cl-stack-icu:u-has-binary-property
          code-point
          (cffi:foreign-enum-value 'cl-stack-icu:u-property (%property-enum property)))))

(defmethod backend-int-property ((backend icu-backend) code-point property)
  (declare (ignore backend))
  (let* ((prop (%property-enum property))
         (v (cl-stack-icu:u-get-int-property-value
             code-point
             (cffi:foreign-enum-value 'cl-stack-icu:u-property prop))))
    (case prop
      (:general-category
       (or (%gc-keyword (cl-stack-icu:u-char-type code-point))
           (%gc-keyword v)))
      ((:canonical-combining-class) v)
      ;; Script / block / bidi / eaw: return ICU int for now (char-name wave later).
      (otherwise v))))

(defmethod backend-script-extensions ((backend icu-backend) code-point)
  (list (backend-int-property backend code-point :script)))

(defmethod backend-char-name ((backend icu-backend) code-point &key (choice :unicode))
  (declare (ignore backend code-point choice))
  ;; Needs u_charName in cl-stack-icu — deferred.
  nil)

(defmethod backend-lookup-name ((backend icu-backend) name)
  (declare (ignore backend name))
  nil)

(defmethod backend-numeric-value ((backend icu-backend) code-point)
  (declare (ignore backend code-point))
  nil)

(defmethod backend-digit-value ((backend icu-backend) code-point &key (radix 10))
  (declare (ignore backend code-point radix))
  nil)

(defmethod backend-mirror-char ((backend icu-backend) code-point)
  (declare (ignore backend))
  code-point)

(defmethod backend-age ((backend icu-backend) code-point)
  (declare (ignore backend code-point))
  nil)

(defmethod backend-property-value-name ((backend icu-backend) property value &key short)
  (declare (ignore backend property short))
  (if (keywordp value)
      (string-downcase (symbol-name value))
      (princ-to-string value)))
