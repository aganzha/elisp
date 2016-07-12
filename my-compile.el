(defun my-compile-rungo ()
  (interactive)
  (let* ((name (buffer-file-name))
         (dirname (file-name-directory name))
         (out "*goout*")
         (outbuff (get-buffer out)))

    ;; (progn
    ;;         (if (get-buffer
    ;;         (kill-buffer out)
    ;;              (get-buffer-create out))))
    (if outbuff        
          (kill-buffer outbuff))
    

    (setq outbuff (get-buffer-create out))
    
    (cd (file-name-directory name))

    (setq default-directory dirname)



    (with-current-buffer outbuff
      (erase-buffer)
      (setq default-directory dirname)
      (gomycompile-mode))


    (start-process-shell-command "gobuild" out (concat "cd " dirname " && ./run.sh"))
    (delete-other-windows)

    (split-window-vertically 26)



    (save-excursion
      (windmove-down)
      (switch-to-buffer outbuff))
    (windmove-up)
    (recenter-top-bottom)

    (message "goooooooooooo!")
    ))


(defun my-compile-jump-go()
  "if file has an attached line num goto that line, ie boom.rb:12"
  (interactive)

  (let ((re "\\([a-z]+\\.go\\):\\([0-9]+\\)"))
    (beginning-of-line)
    (search-forward-regexp re (line-end-position) t)
    (let ((line-num  (string-to-number (match-string 2)))
          (file-name (match-string 1)))
      (message "============================found regexps: %s %s" file-name line-num)
      (switch-to-buffer (find-file-noselect (concat default-directory "/" file-name)))
      (goto-line line-num))))

(setq go-highlights
      '(("panic\\|abnormally" . font-lock-warning-face)
        ("[a-z]+\\.go" . font-lock-builtin-face)
        ))

(define-derived-mode gomycompile-mode fundamental-mode
  (setq font-lock-defaults '(go-highlights))
  (setq mode-name "gomycompile"))

(add-hook 'gomycompile-mode-hook
          (lambda ()  (local-set-key (kbd "RET") 'my-compile-jump-go)))


(defun my-compile-runwebpack ()
  (interactive)
  (let* ((name (buffer-file-name))
         (dirname (file-name-directory name))
         (out "*compileout*")
         (outbuff (get-buffer-create out)))
    (cd (file-name-directory name))

    ;;(set-buffer out)

    (setq default-directory dirname)

    (with-current-buffer outbuff
      (erase-buffer)
      (setq default-directory dirname)
      (tsxmycompile-mode))

    (start-process-shell-command "webpack" out (concat "cd " dirname " && rm -f *_flymake.tsx && webpack"))

    (delete-other-windows)

    (split-window-vertically 26)

    ;; (let ((window (split-window-vertically 26)))
    ;;   (message (format "window: %s" window)))

    (save-excursion
      (windmove-down)
      (switch-to-buffer outbuff))
    (windmove-up)
    (recenter-top-bottom)

    ;; (call-process (concat (file-name-directory name) "/webpack") nil out nil)
    ;; (message (buffer-substring (point-min) (point-max)))

    ))

(defun my-compile-runtsc ()
  (interactive)
  (let* ((name (buffer-file-name))
         (me (current-buffer))
         (dirname (file-name-directory name))
         (out "*compileout*")
         (outbuff (get-buffer-create out)))
    (cd (file-name-directory name))
    ;;(set-buffer outbuff)

    (setq default-directory dirname)

    (with-current-buffer outbuff
      (erase-buffer)
      (setq default-directory dirname)
      (tsxmycompile-mode))

    (start-process-shell-command "tsc" outbuff (concat "cd " dirname " && rm -f *_flymake.tsx && tsc"))

    (delete-other-windows)

    (let ((window (split-window-vertically 26)))
      (message (format "window: %s" window))
      )

    (save-excursion
      (windmove-down)
      (switch-to-buffer outbuff))
    (windmove-up)
    (recenter-top-bottom)

    ))


(defun my-compile-jump-tsx()
  "if file has an attached line num goto that line, ie boom.rb:12"
  (interactive)
  (let ((line-num (progn
                    (beginning-of-line)
                    (search-forward-regexp "tsx?\n?\(\\([0-9]+\\)," (line-end-position) t)
                    (string-to-number (match-string 1))))
        (file-name (progn
                     (beginning-of-line)
                     (search-forward-regexp "[a-z]+\\.+tsx?" (line-end-position) t)
                     (match-string 0))))
    (message "============================ found regexps: %s %s" file-name line-num)
    (switch-to-buffer (find-file-noselect (concat default-directory "/" file-name)))
    (goto-line line-num)))

(setq tsx-highlights
      '(("error\\|abnormally" . font-lock-warning-face)
        ("[a-z]+\\.tsx?" . font-lock-builtin-face)
        ))

(define-derived-mode tsxmycompile-mode fundamental-mode
  (setq font-lock-defaults '(tsx-highlights))
  (setq mode-name "tsxmycompile"))

(add-hook 'tsxmycompile-mode-hook
          (lambda ()  (local-set-key (kbd "RET") 'my-compile-jump-tsx)))



























;;---------------------------- OLD SHIT -----------------------------------

(defun my-compile ()
  (interactive)
  (let* ((name (buffer-file-name))
         (jsx (if (string-match "tsx" name) t nil))
         (webpack (if (string-match "tsx" name) t nil))
         (out "*compileout*"))
    (if (get-buffer out)
        (progn
          (set-buffer out)
          (erase-buffer)
          ))
    ;; (if (get-buffer out)
    ;;     (kill-buffer out))
    (cd (file-name-directory name))
    (if (string-match "scss" name)
        ;;(call-process "compass" nil out nil "compile")
        (start-process "compass" out "compass" "compile")
      (if jsx
          (progn
            (message "compile tsx")
            ;;(call-process "tsc" nil out nil "--module" "amd" "--jsx" "react" "--target" "ES5" "--experimentalDecorators" "--emitDecoratorMetadata" name)
            (start-process "typescript" out "tsc" "--module" "amd" "--jsx" "react" "--target" "ES5" "--experimentalDecorators" "--emitDecoratorMetadata" name)
            )
        (progn
          (message "compile ts")
          ;;(call-process "tsc" nil out nil "--module" "amd" "--target" "ES5" "--experimentalDecorators" "--emitDecoratorMetadata" name)
          (start-process "typescript" out "tsc" "--module" "amd" "--target" "ES5" "--experimentalDecorators" "--emitDecoratorMetadata" name)
          )))
    (let* ((bu (current-buffer))
           (mock (set-buffer out))
           (answer (buffer-substring (point-min) (point-max)))
           (mock1 (set-buffer bu))
           (full-answer (if (= (length answer) 0) "compiled!" answer)))
      (message full-answer))))


(defun my-compile-project ()
  (interactive)
  (let ((name (buffer-file-name))
        (out "*compileout*"))
    (if (get-buffer out)
        (progn
          (set-buffer out)
          (erase-buffer)
          ))
    (cd (file-name-directory name))

    ;;(call-process "tsc" nil out nil)
    ;;(start-process "rm" "out" "rm" "*flymake*")
    (start-process "typescript" out "tsc")

    (let* ((bu (current-buffer))
           (answer (buffer-substring (point-min) (point-max)))
           (full-answer (if (= (length answer) 0) "compiled!" answer)))
      ;;(kill-buffer out)
      (message full-answer))))





(defun ts-for-js()
  (interactive)
  (let ((name (buffer-file-name)))
    (if (string-match "\\.tsx?" (buffer-file-name))
        (switch-to-buffer (find-file-noselect (replace-regexp-in-string "\\.ts" ".js" (replace-regexp-in-string "\\.tsx" ".js" name)) t))
      (switch-to-buffer (find-file-noselect (replace-regexp-in-string "\\.js" ".ts" name) t)))))



;; (defun flymake-typescript-init ()
;;   (list "tsc")
;;   )


(provide 'my-compile)
