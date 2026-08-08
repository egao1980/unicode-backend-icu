;;;; BreakIterator — grapheme/word themes from ICU ubrk / PyICU BreakIterator.

(in-package #:unicode-backend-icu/tests)

(defun %grapheme-ends (text)
  (let ((ends '()))
    (map-breaks (lambda (start end)
                  (declare (ignore start))
                  (push end ends))
                text :kind :grapheme)
    (nreverse ends)))

(deftest grapheme-ascii
  (ok (equal (%grapheme-ends "ab") '(1 2)))
  (let ((it (make-break-iterator :grapheme)))
    (break-set-text it "ab")
    (ok (= (break-first it) 0))
    (ok (= (break-next it) 1))
    (ok (break-is-boundary-p it 0))
    (ok (break-is-boundary-p it 1))))

(deftest grapheme-combining-mark
  ;; e + combining acute = one extended grapheme cluster
  (let ((s (%s #x65 #x301)))
    (ok (equal (%grapheme-ends s) (list (length s))))))

(deftest word-breaks-en
  (let ((ends '()))
    (map-breaks (lambda (s e) (declare (ignore s)) (push e ends))
                "Hello, world" :kind :word :locale "en")
    (ok (plusp (length ends)))
    (ok (= (car (last (nreverse ends))) (length "Hello, world")))))

(deftest break-navigation
  (let ((it (make-break-iterator :grapheme)))
    (break-set-text it "xyz")
    (ok (= (break-first it) 0))
    (ok (= (break-following it 1) 2))
    (ok (= (break-preceding it 2) 1))
    (ok (= (break-last it) 3))))
