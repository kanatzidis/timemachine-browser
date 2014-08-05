(load "tokenizer.lisp")
(defun find-latest ()
  (let* ((path (reverse (tokens (ls-item "Latest") #'constituent 0)))
         (latest (pop path)))
    latest))
(defun concat (x y)
  (concatenate 'string x y))
(defun make-path (lst)
    (reduce #'concat lst))
(defun ls (&optional pathtoget hidden)
  (format t "path: ~A~%" pathtoget)
  (let* ((lspath (if (eq t hidden)
                   pathtoget
                   (append cwd (list pathtoget))))
         (path (if (eq t hidden)
                 lspath
                 (make-path lspath))))
    (let ((run (run-program
      "sudo" (list "ls" "-l" path)
      :search t
      :output :stream
      :input t
      :wait nil)))
      (let ((str (process-output run)))
        str))))
    ;; This is what happens when you "double click" on a file or folder in the browser.
(defun ls-item (&optional path hidden)
  (let ((str (ls path hidden)) (item nil))
    (do ((line (read-line str nil 'eof)
               (read-line str nil 'eof)))
         ((eql line 'eof) item)
         (format t "~A~%" hidden)
         (if (or
               (equal "total" (subseq line 0 5))
               (member "->" (tokens line #'constituent 0) :test #'equal))
           (setf item (concatenate 'string line (list #\Return) (build-dir str))) ; Directory
           (let ((line-items (tokens line #'constituent 0)))
             (if (member "dialout" line-items :test #'equal)
               (setf item (prep-dl line-items)) ; File
               (setf item (get-linkdir line-items)))))) ; Link
    (close str)
    item))
(defun build-dir (str)
  (do ((line (read-line str nil 'eof)
             (read-line str nil 'eof))
       (dir "" (concatenate 'string dir (list #\Newline) line)))
    ((eql line 'eof) dir)))
(defun get-linkdir (tokens)
  (format t "getting~%")
  (ls-item (concatenate 'string
                        tmfolder "dir_" (car (subseq tokens 1))) t))
(defun prep-dl (f)
  (format t "This does nothing"))
(defun listdir (&optional str)
  (format t "~A~%" (ls-item str)))
(defun cd (path)
  (setf cwd (append cwd (list path)))
  cwd)
(defparameter drivepath "/media/kanatzidis/Elements/")
(defparameter tmfolder
  (concatenate 'string drivepath
               ".HFS+\ Private\ Directory\ Data" (list #\Return) "/"))
(defparameter backupfolder "Backups.backupdb/Gregori’s\ MacBook\ Pro/")
(defparameter cwd (list drivepath backupfolder))
(defun setup ()
  (setf cwd (append cwd (list (find-latest)))))

cwd is a virtual path referring to where a file/dir would be if tm wasn't stupid.
truepath is the folder to call ls from, is set when cd into hidden dir.
All calls to ls and cd should break down the path and determine hidden vs true.
  After the true path, each successive component should be get-linkdir'd from the previous.
  Then ls returns the final get-linkdir.
Each path previously visited will be added to a structure with its full path and its type.
