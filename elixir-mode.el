(ignore-errors
  (unload-feature 'elixir-mode))

(require 'treesit)

(defgroup elixir nil
  "Major mode for editing Elixir code."
  :prefix "elixir-"
  :group 'languages)

(defcustom elixir-indent-level 2
  "Indentation of Elixir statements."
  :type 'integer
  :safe 'integerp)

(defvar elixir-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Operators
    ;; (modify-syntax-entry ?< "." table)
    ;; (modify-syntax-entry ?> "." table)
    ;; (modify-syntax-entry ?& "." table)
    ;; (modify-syntax-entry ?| "." table)
    (modify-syntax-entry ?= "." table)
    ;; (modify-syntax-entry ?/ "." table)
    ;; (modify-syntax-entry ?+ "." table)
    ;; (modify-syntax-entry ?* "." table)
    ;; (modify-syntax-entry ?- "." table)
    (modify-syntax-entry ?: "'" table)

    ;; Comments
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)

    ;; Strings
    ;; (modify-syntax-entry ?\' "\"'" table)
    ;; (modify-syntax-entry ?\" "\"\"" table)

    ;; Symbol constituents
    ;; (modify-syntax-entry ?! "_" table)
    ;; (modify-syntax-entry ?? "_" table)
    ;; (modify-syntax-entry ?_ "_" table)
    ;; (modify-syntax-entry ?@ "_" table)

    ;; expressions
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\{ "(}" table)
    (modify-syntax-entry ?\} "){" table)
    (modify-syntax-entry ?\[ "(]" table)
    (modify-syntax-entry ?\] ")[" table)

    ;; escape character
    ;; (modify-syntax-entry ?# "\\" table)

    (modify-syntax-entry ?% "'" table)

    table)
  "Syntax table to use in Elixir mode.")



(defvar elixir--treesit-keywords
  '("do" "end"))

(defvar elixir--treesit-builtins
  '("Enum" "List" "Map"))

(defvar elixir--treesit-constants
  '("@tag"))

(defvar elixir--treesit-operators
  '("-" "+" ">"))

(defvar elixir--treesit-special-attributes
  '("__MODULE__" "__STACKTRACE__"))

(defvar elixir--treesit-exceptions
  '("Error"))

(defvar elixir-attribute-face 'elixir-attribute-face)
(defface elixir-attribute-face
  '((t (:inherit font-lock-preprocessor-face)))
  "For use with module attribute tokens.")

(defvar elixir-atom-face 'elixir-atom-face)
(defface elixir-atom-face
  '((t (:inherit font-lock-builtin-face)))
  "For use with atoms & map keys.")

(defvar elixir-number-face 'elixir-number-face)
(defface elixir-number-face
  '((t (:inherit default)))
  "For use with numbers.")

(defun elixir--treesit-beginning-of-defun (&optional arg)
  (let ((arg (or arg 1)))
    (if (> arg 0)
        ;; Go backward.
        (while (and (> arg 0)
                    (treesit-search-forward-goto
                     "do_block" 'start nil t))
          (setq arg (1- arg)))
      ;; Go forward.
      (while (and (< arg 0)
                  (treesit-search-forward-goto
                   "do_block" 'start))
        (setq arg (1+ arg))))))

(defun elixir--treesit-end-of-defun (&optional arg)
  (let ((arg (or arg 1)))
    (if (< arg 0)
        ;; Go backward.
        (while (and (< arg 0)
                    (treesit-search-forward-goto
                     "do_block" 'end nil t))
          (setq arg (1+ arg)))
      ;; Go forward.
      (while (and (> arg 0)
                  (treesit-search-forward-goto
                   "do_block" 'end))
        (setq arg (1- arg))))))


(defvar elixir--treesit-font-lock-settings
  (treesit-font-lock-rules
   :language 'elixir
   :level 1
   `(
     (call
      target: (identifier) @font-lock-keyword-face)
     (unary_operator) @elixir-attribute-face
     (call (arguments) @font-lock-type-face)
     (keyword) @elixir-atom-face
     (do_block ("do") @font-lock-keyword-face)
     (do_block ("end") @font-lock-keyword-face)
     (identifier) @font-lock-variable-name-face
     (comment) @font-lock-comment-face
     (string) @elixir--treesit-fontify-string
     ))
  "Tree-sitter font-lock settings.")


(defvar elixir--treesit-indent-rules
  (let ((offset elixir-indent-level))
    `((elixir
       ((node-is "end") parent-bol 0)
       ((node-is "]") parent-bol 0)
       ((parent-is "do_block") parent-bol ,offset)
       ((parent-is "list") parent-bol ,offset)
       ((parent-is "keywords") parent-bol 0)
       ))))

;;;###autoload
(define-derived-mode elixir-mode prog-mode "Elixir"
  (treesit-parser-create 'elixir)


  ;; This turns off the syntax-based font-lock for comments and
  ;; strings.  So it doesn’t override tree-sitter’s fontification.
  (setq-local font-lock-keywords-only t)
  (setq-local treesit-font-lock-settings
              elixir--treesit-font-lock-settings)
  (treesit-font-lock-enable)


  (setq-local treesit-simple-indent-rules elixir--treesit-indent-rules)
  (setq-local indent-line-function #'treesit-indent)

  (setq-local beginning-of-defun-function #'elixir--treesit-beginning-of-defun)
  (setq-local end-of-defun-function #'elixir--treesit-end-of-defun)


  (setq-local comment-start "# ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "#+ *"))


;;;###autoload
(progn
  (add-to-list 'auto-mode-alist '("\\.elixir\\'" . elixir-mode))
  (add-to-list 'auto-mode-alist '("\\.ex\\'" . elixir-mode))
  (add-to-list 'auto-mode-alist '("\\.exs\\'" . elixir-mode))
  (add-to-list 'auto-mode-alist '("mix\\.lock" . elixir-mode)))

(provide 'elixir-mode)
;;; elixir-custom-mode.el ends here


