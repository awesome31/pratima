#!/bin/bash
# Double-click this file to send the website to GitHub. Vercel then puts it online.
cd "$(dirname "$0")" || exit 1
clear
REPO="awesome31/pratima"

say() { echo "  $1"; }
pause() { echo ""; read -r -p "  Press Return to close this window. " _; }

echo ""
say "PUBLISH THE WEBSITE"
say "-------------------"
echo ""

if ! command -v git >/dev/null 2>&1; then
  say "This Mac does not have git yet. macOS will offer to install it; accept, wait"
  say "for it to finish, then double-click this file again."
  git --version >/dev/null 2>&1
  pause; exit 1
fi

# Record anything that has been saved in the editor but not yet recorded.
if [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit --quiet -m "Update website, $(date '+%-d %b %Y %H:%M')"
  say "Your latest saved changes have been recorded."
  echo ""
fi

say "What would you like to do?"
echo ""
say "  1  Send a preview   (a private link; your real website does not change)"
say "  2  Go live          (replaces what visitors see on your real website)"
say "  3  Cancel"
echo ""
read -r -p "  Type 1, 2 or 3 and press Return: " choice
echo ""

case "$choice" in
  1) BRANCH="new-site" ;;
  2) read -r -p "  This changes your real website. Type LIVE and press Return to confirm: " sure
     if [ "$sure" != "LIVE" ]; then say "Cancelled. Nothing was sent."; pause; exit 0; fi
     BRANCH="main"; echo "" ;;
  *) say "Cancelled. Nothing was sent."; pause; exit 0 ;;
esac

say "GitHub may now ask you to sign in:"
say "  Username: your GitHub username"
say "  Password: paste your ACCESS TOKEN (it starts with ghp_), not your GitHub password."
say "            Nothing shows on screen while you paste. That is normal. Then press Return."
say "No token yet? README.md, section \"Signing in to GitHub\", shows how to make one."
echo ""

if git push origin "HEAD:$BRANCH"; then
  echo ""
  if [ "$BRANCH" = "main" ]; then
    say "Done. Your real website will update in a minute or two."
  else
    say "Done. Vercel is building a preview."
    say "To find its link: open https://github.com/$REPO/tree/new-site"
    say "and click the green tick beside the latest change."
  fi
else
  echo ""
  say "That did not go through. Nothing on the website has changed, and your work is"
  say "safe on this computer. The usual reasons:"
  say "  - \"Invalid username or token\": the password box needs a token, not your password."
  say "  - \"403\" or \"denied\": your GitHub account has no write access to $REPO."
  say "    The owner adds you under the repository's Settings > Collaborators."
  say "  - \"rejected\": someone else changed the website on GitHub. Open this folder"
  say "    in Claude and ask it to bring the two versions together."
fi
pause
