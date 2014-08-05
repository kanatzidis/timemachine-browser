(load "tokenizer.lisp")
(defparameter drivepath "/media/kanatzidis/Elements/")
(defparameter tmfolder (concatenate 'string drivepath ".HFS+ Private Directory Data" (list #\Return) "/"))
(defparameter backupfolder "Backups.backupdb/")
(defun ls (path)
  (let ((run (run-program
    "sudo" (list "ls" "-l" path)
    :search t
    :output :stream
    :input t
    :wait nil)))
    (let ((str (process-output run)))
      (format t "~%Enter your sudo password:~%")
      (read-line)
      (finish-output str)
      str)))
    ;; This is what happens when you "double click" on a file or folder in the browser.
(defun get-item (path)
  (let ((str (ls path)) (item nil))
    (do ((line (read-line str nil 'eof)
               (read-line str nil 'eof)))
         ((eql line 'eof) item)
         (format t "~A~%" line)
         (if (equal "total" (subseq line 0 5))
           (setf item (build-dir str)) ; Directory
           (let ((line-items (tokens line #'constituent 0)))
             (if (member "dialout" line-items)
               (setf item (prep-dl line-items)) ; File
               (if (equal (car line-items) "ls")
                 (setf item (get-linkdir line-items)) ; Link
                 nil)))))
    (close str)
    item))
(defun build-dir (str)
  (do ((line (read-line str nil 'eof)
             (read-line str nil 'eof))
       (dir "" (concatenate 'string dir (list #\Newline) line)))
    ((eql line 'eof) dir)))
(defun get-linkdir (tokens)
  (get-item (concatenate 'string tmfolder "dir_" (car (subseq tokens 1)))))
(defun prep-dl (f)
  (format t "This does nothing"))
(defun listdir ()
  (format t "result: ~A" (get-item (concatenate 'string tmfolder "dir_2759790"))))
(listdir)

