(in-package #:unicode-backend-icu)

(defun %zero-error ()
  (cffi:foreign-enum-value 'cl-stack-icu:u-error-code :zero-error))

(defun %optionp (options key)
  "True when OPTIONS (keyword list and/or plist) enables KEY."
  (or (find key options :test #'eq)
      (and (listp options)
           (evenp (length options))
           (getf options key))))

;;; ICU UCharCategory → Unicode General_Category short keywords (:lu …).
(defparameter *gc-short*
  #(:cn :lu :ll :lt :lm :lo :mn :me :mc :nd :nl :no
    :zs :zl :zp :cc :cf :co :cs :pd :ps :pe :pc :po
    :sm :sc :sk :so :pi :pf))

(defun %gc-keyword (category-int)
  (when (and (integerp category-int)
             (<= 0 category-int)
             (< category-int (length *gc-short*)))
    (aref *gc-short* category-int)))

(defun %property-enum (property)
  "Protocol keyword → grovelled u-property enum keyword (same names for most)."
  (case property
    (:general-category :general-category)
    (:bidi-class :bidi-class)
    (:canonical-combining-class :canonical-combining-class)
    (:block :block)
    (:script :script)
    (:east-asian-width :east-asian-width)
    (:white-space :white-space)
    (otherwise property)))

(defun call-with-uchars (string fn)
  "Convert STRING to a temporary UChar buffer; call FN with (pointer uchar-count)."
  (cffi:with-foreign-string (utf8 (string string) :encoding :utf-8)
    (cffi:with-foreign-objects ((err :int) (needed :int32))
      (setf (cffi:mem-ref err :int) (%zero-error))
      (cl-stack-icu:u-str-from-utf8 (cffi:null-pointer) 0 needed utf8 -1 err)
      (let ((n (cffi:mem-ref needed :int32)))
        (setf (cffi:mem-ref err :int) (%zero-error))
        (cffi:with-foreign-pointer (buf (* (cffi:foreign-type-size 'cl-stack-icu:u-char)
                                          (1+ (max n 0))))
          (cl-stack-icu:u-str-from-utf8 buf (1+ n) needed utf8 -1 err)
          (cl-stack-icu:check-icu (cffi:mem-ref err :int) "u-str-from-utf8")
          (funcall fn buf (cffi:mem-ref needed :int32)))))))

(defun %normalize-instance (form err)
  (ecase form
    (:nfc (cl-stack-icu:unorm2-get-nfc-instance err))
    (:nfd (cl-stack-icu:unorm2-get-nfd-instance err))
    (:nfkc (cl-stack-icu:unorm2-get-nfkc-instance err))
    (:nfkd (cl-stack-icu:unorm2-get-nfkd-instance err))
    (:nfkc-casefold (cl-stack-icu:unorm2-get-nfkc-casefold-instance err))))

(defun %uidna-options (options)
  "Protocol option keywords → ICU UIDNA bitflags."
  (let ((opts cl-stack-icu:+uidna-default+))
    (when (%optionp options :std3)
      (setf opts (logior opts cl-stack-icu:+uidna-use-std3-rules+)))
    (when (%optionp options :check-bidi)
      (setf opts (logior opts cl-stack-icu:+uidna-check-bidi+)))
    (when (%optionp options :check-contextj)
      (setf opts (logior opts cl-stack-icu:+uidna-check-contextj+)))
    (when (%optionp options :check-contexto)
      (setf opts (logior opts cl-stack-icu:+uidna-check-contexto+)))
    ;; UIDNA_DEFAULT already implies nontransitional; transitional clears those bits.
    (when (%optionp options :transitional)
      (setf opts (logandc2 opts
                           (logior cl-stack-icu:+uidna-nontransitional-to-ascii+
                                   cl-stack-icu:+uidna-nontransitional-to-unicode+))))
    opts))
