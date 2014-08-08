(load "tokenizer.lisp")

; This can be modified to be a utility function for soft links
(defun find-latest ()
  (let* ((path (reverse (tokens (ls-path "Latest") #'constituent 0)))
         (latest (pop path)))
    latest))

(defparameter drivepath "/media/kanatzidis/Elements")
(defparameter tmfolder
  (concatenate 'string drivepath
               "/.HFS+\ Private\ Directory\ Data" (list #\Return) "/"))
(defparameter backupfolder
  (concatenate 'string drivepath "/Backups.backupdb/Gregori’s\ MacBook\ Pro/"))
(defparameter cwd nil)
(defparameter known nil)

(defun main ()
  (setf cwd nil)
  (cd (find-latest))
  (do ((input (read-line) (read-line)))
    ((equal input "exit"))
    (format t "~%~A> " (concat cwd))
    (let ((cmd (tokens input #'constituent 0)))
      (if (or (equal (car cmd) "ls")
              (equal (car cmd) "cd"))
        (apply (read-from-string (car cmd))
               (list (format nil "~{~A~^ ~}" (cdr cmd))))
        (format t "~% Error: You must use ls or cd with one argument.~%")))))

(defstruct dir
  type
  location
  from
  name)

; Takes a string representing a path.
(defun cd (path)
  (let ((path-components (tokens path #'slash 0))
        (newpath cwd))
    (dolist (comp path-components)
      (if (equal comp "..")
        (progn
        (pop cwd)
        (pop newpath))
        (push comp newpath)))
    (format t "~A~%" (ch-dir newpath))))

(defun ls (path)
  (let ((old cwd))
    (cd path)
    (setf cwd old)))

; Takes a list representing the virtual path.
; Changes the cwd and returns the result of ls.
(defun ch-dir (path)
  (let ((tols (pathify path)))
    (if (eq (car tols) nil)
      (format t "Error: path '~A' could not be found.~%" (cadr tols))
      (progn
        (ls-path)))))

; Takes a virtual path and returns a list of form:
; (exists virtualpath full_list_of_virtual_paths)
(defun pathify (path)
  (let ((newcwd nil)
        (lst (reverse path))
        (vpath (concat path)))
    (do ((comp (pop lst) (pop lst)))
      ((eq comp nil) (list t vpath newcwd))
      (if (stringp comp)
        (let ((dir (get-path comp (car newcwd))))
          (if dir
            (progn
              (push dir cwd)
              (push dir newcwd))
            (return (list nil vpath))))
        (push comp newcwd)))))

; Takes a string an optionally a dir struct
; Returns a dir struct representing the string.
(defun get-path (pathstring &optional from)
  (if (eq from nil)
    (setf from (car cwd))
    (if (dir-p from)
      (setf from (dir-location from))))
  (let* ((structs (get-structs pathstring))
         (struct (car (member from structs :test #'equal :key #'dir-from))))
    (if struct
      struct
      (let ((unknown (new-dir pathstring from)))
        (if unknown
          (progn
            (push unknown known)
            unknown)
          nil)))))

; Takes a directory pathname and checks to see
; if we already know about it. If so, return it,
; if not, nil.
(defun get-structs (path)
  (let ((structs nil))
    (dolist (dir known)
      (if (equal (dir-location dir) path)
        (push dir structs)))
    structs))

; Creates a new dir struct from a string and its parent dir struct
(defun new-dir (path from)
  (let* ((res (ls-path path))
         (tokenlst (tokens (subseq res 0 (position #\Newline res))
                           #'constituent 0)))
    (if (member "total" tokenlst :test #'equal)
      (make-dir :type 'real :from from :location path :name path)
      (if (or (member "dialout" tokenlst :test #'equal)
              (member "No" tokenlst :test #'equal))
        nil
        (make-dir :type 'virtual :from from :name path
                  :location
                  (concatenate 'string "dir_"
                               (car (subseq
                                      (tokens res #'constituent 0) 1))))))))

; Takes a list of strings and dirs and returns the real path.
(defun concat (lst)
  (let ((real-path ""))
    (dolist (obj lst)
      (cond ((stringp obj) (setf real-path
                                 (concatenate 'string obj "/" real-path)))
            ((dir-p obj) (progn
                           (setf real-path
                                 (concatenate 'string
                                        (dir-location obj) "/" real-path))
                          (if (eq (dir-type obj) 'virtual)
                            (return-from concat
                                         (concatenate 'string tmfolder real-path)))))
            ((not (or (stringp obj)(dir-p obj))) (format t "Something went wrong: ~A~%" obj))))
    (concatenate 'string backupfolder real-path)))

; Takes a string and returns the raw ls result.
(defun ls-path (&optional path)
  (let ((cwdpath (if path (concat (cons path cwd))
                   (concat cwd))))
    (let ((tmp (subseq cwdpath (- (length cwdpath) 1) (length cwdpath))))
      (if (equal tmp "/")
        (setf cwdpath (subseq cwdpath 0 (- (length cwdpath) 1)))))
    (let ((str (process-output (run-program
          "sudo" (list "ls" "-l" cwdpath)
          :search t
          :output :stream
          :input t
          :wait nil))))
      (do ((line (read-line str nil 'eof)
                 (read-line str nil 'eof))
           (ret "" (concatenate 'string ret line (list #\Newline))))
        ((eq line 'eof) (progn (close str) ret))))))
