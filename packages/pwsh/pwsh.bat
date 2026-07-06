@echo off
:: Emacs will pass '-Command "your-command"' to this script.
:: We inject '-NoProfile' right before it.
pwsh -NoProfile %*