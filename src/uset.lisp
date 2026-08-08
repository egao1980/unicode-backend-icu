(in-package #:unicode-backend-icu)

(defun %uset-ptr (set)
  (uset-raw set))

(defun %span-condition (contained)
  (cffi:foreign-enum-value 'cl-stack-icu:u-set-span-condition
                           (if contained :contained :not-contained)))

(defmethod backend-make-unicode-set ((backend icu-backend) &key pattern freeze)
  (declare (ignore backend))
  (cffi:with-foreign-object (err :int)
    (setf (cffi:mem-ref err :int) (%zero-error))
    (let ((ptr
            (if pattern
                (call-with-uchars
                 (string pattern)
                 (lambda (p n)
                   (setf (cffi:mem-ref err :int) (%zero-error))
                   (cl-stack-icu:uset-open-pattern p n err)))
                (cl-stack-icu:uset-open-empty))))
      (when pattern
        (cl-stack-icu:check-icu (cffi:mem-ref err :int) "uset-open-pattern"))
      (when freeze
        (cl-stack-icu:uset-freeze ptr))
      (let ((set (make-instance 'unicode-set :raw ptr :pattern pattern)))
        (tg:finalize set (lambda ()
                           (ignore-errors (cl-stack-icu:uset-close ptr))))
        set))))

(defmethod backend-uset-contains-p ((backend icu-backend) set object)
  (declare (ignore backend))
  (cond
    ((integerp object)
     (plusp (cl-stack-icu:uset-contains (%uset-ptr set) object)))
    (t
     (call-with-uchars
      (string object)
      (lambda (p n)
        (plusp (cl-stack-icu:uset-contains-string (%uset-ptr set) p n)))))))

(defmethod backend-uset-span ((backend icu-backend) set string &key (start 0) end contained)
  (declare (ignore backend start end))
  ;; ICU span is over whole UTF-16 string; START/END reserved for protocol.
  (call-with-uchars
   string
   (lambda (p n)
     (cl-stack-icu:uset-span (%uset-ptr set) p n (%span-condition contained)))))

(defmethod backend-uset-span-back ((backend icu-backend) set string &key start end contained)
  (declare (ignore backend start end))
  (call-with-uchars
   string
   (lambda (p n)
     (cl-stack-icu:uset-span-back (%uset-ptr set) p n (%span-condition contained)))))

(defmethod backend-uset-size ((backend icu-backend) set)
  (declare (ignore backend))
  (cl-stack-icu:uset-size (%uset-ptr set)))

(defmethod backend-uset-empty-p ((backend icu-backend) set)
  (declare (ignore backend))
  (plusp (cl-stack-icu:uset-is-empty (%uset-ptr set))))

(defmethod backend-uset-complement ((backend icu-backend) set)
  (declare (ignore backend))
  (cl-stack-icu:uset-complement (%uset-ptr set))
  set)

(defmethod backend-uset-add ((backend icu-backend) set object)
  (declare (ignore backend))
  (cond
    ((integerp object)
     (cl-stack-icu:uset-add (%uset-ptr set) object))
    (t
     (call-with-uchars
      (string object)
      (lambda (p n)
        (cl-stack-icu:uset-add-string (%uset-ptr set) p n)))))
  set)

(defmethod backend-uset-remove ((backend icu-backend) set object)
  (declare (ignore backend))
  (cond
    ((integerp object)
     (cl-stack-icu:uset-remove (%uset-ptr set) object))
    (t
     (call-with-uchars
      (string object)
      (lambda (p n)
        (cl-stack-icu:uset-remove-string (%uset-ptr set) p n)))))
  set)

(defmethod backend-uset-retain ((backend icu-backend) set other)
  (declare (ignore backend))
  (cl-stack-icu:uset-retain-all (%uset-ptr set) (%uset-ptr other))
  set)

(defmethod backend-uset-clear ((backend icu-backend) set)
  (declare (ignore backend))
  (cl-stack-icu:uset-clear (%uset-ptr set))
  set)
