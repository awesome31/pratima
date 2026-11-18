# Pratima Jain: personal website

This folder is everything needed to change your website and put it online. You do not need to know any code.

**The short version**

1. Double-click **Edit my website** to change words and photos.
2. Double-click **Publish to GitHub** to put the changes online.

The rest of this page explains each step, and what to do when something goes wrong.

---

## 1. Changing words and photos

1. In Finder, open this folder and double-click **Edit my website** (its full name is `Edit my website.command`).
   - The first time, macOS may say it "cannot be opened because it is from an unidentified developer". If so, right-click the file, choose **Open**, then **Open** again. You only need to do this once.
2. A small black Terminal window opens, and then the editor opens in your web browser. **Leave the black window open** while you edit; it is what runs the editor.
3. In the editor:
   - **Pick a page** on the left: Home, About, Ideas, Speaking, Contact, Shared bits or Photos.
   - **Change the words** in the boxes. Titles with a pink **+** open when you click them.
   - Press **Save and preview**. The preview on the right shows your website with the change. Use **Phone** above the preview to see it at phone size.
   - Not what you wanted? Press **Undo last save**. Each press steps back one save.
4. When you are finished, close the browser tab and the black window.

**Lists** (ideas, career rows, talks, numbers): use **↑** and **↓** to reorder, **×** to remove, and the dashed **+ Add** button to add one.

**Leaving a box empty** hides that line on the website. An empty link hides its button.

**Photos**: open the Photos tab and choose a new file for any of the three photos. It is resized for the web automatically. There is no undo for photos, so keep your originals.

**What the editor cannot change**: colours, fonts, the layout, the drawings, the hello greetings and the game. Those are design decisions; see section 5.

Saving only changes the copy on your computer. Your real website does not change until you publish.

## 2. Putting changes online

Your website is published in two steps: this folder sends the files to **GitHub** (an online store for the files), and **Vercel** (the hosting service) notices and puts them on your web address a minute or two later.

1. Double-click **Publish to GitHub** (`Publish to GitHub.command`).
2. It asks what you want:
   - **1, Send a preview**: puts the changes on a private preview link. Your real website does not change. Use this first.
   - **2, Go live**: replaces what visitors see. You type `LIVE` to confirm.
3. GitHub may ask you to sign in:
   - **Username**: your GitHub username.
   - **Password**: paste your **access token**, not your GitHub password. Nothing appears while you paste; that is normal. Press Return.

You can also press **Publish** inside the editor. If GitHub needs you to sign in, the editor will tell you to use **Publish to GitHub** instead, because only the Terminal window can ask for your token.

**Finding the preview link**: open `https://github.com/awesome31/pratima/tree/new-site` in your browser and click the green tick beside the latest change. Vercel's preview link is in the list that opens.

## 3. Signing in to GitHub (one time per token)

GitHub does not accept your normal password for publishing. It needs an **access token**, a long code that works like a password for this one job.

**Before you start: you need permission.** The repository `awesome31/pratima` belongs to the `awesome31` GitHub account. Your own GitHub account must be added to it as a collaborator, or publishing will be refused with a "403" or "denied" message. The owner does this on GitHub under the repository's **Settings → Collaborators → Add people**. You will get an email invitation to accept.

**Making a token:**

1. Sign in to github.com in your browser and go to `github.com/settings/tokens`.
2. Choose **Generate new token → Generate new token (classic)**.
3. Note: `Publish website`. Expiration: choose how long it should last.
4. Tick the **repo** box and nothing else.
5. Click **Generate token** and copy it. It starts with `ghp_`. GitHub shows it only once, so keep it in your password manager.

Use the **classic** kind: the newer "fine-grained" tokens cannot reach a repository that belongs to another account.

## 4. When something goes wrong

| What you see | What it means | What to do |
| --- | --- | --- |
| "Invalid username or token. Password authentication is not supported" | You typed your GitHub password | Paste the access token instead (section 3) |
| "403", "Permission denied" or "denied to …" | Your GitHub account cannot write to `awesome31/pratima` | Ask the owner to add you as a collaborator (section 3) |
| "rejected" or "fetch first" | Someone changed the website on GitHub since you last published | Open this folder in Claude and ask it to bring the two versions together |
| The editor says "The editor has stopped running" | The black Terminal window was closed | Double-click **Edit my website** again, then press Save |
| "That file could not be used as a photo" | The photo file is a type macOS cannot read | Export it as JPG from the Photos app and try again |
| A word I typed does not get underlined, struck or circled | The phrase in that box does not exactly match the text | Copy the words straight from the sentence above it |
| "This Mac does not have Ruby" or git | A developer tool is missing on a new Mac | Accept macOS's offer to install the command line tools, or ask Claude |

Your work is never lost when publishing fails: everything stays saved in this folder.

## 5. Bigger changes: ask Claude

For anything the editor cannot do (a new page, a different colour, a new drawing, a new section, changing the game), open this folder in Claude and describe what you want. Claude should read **HANDOVER.md** first; it explains how the site is built and the rules it follows. You can say: *"Read HANDOVER.md, then …"*.

## 6. Keeping a safe copy

This folder is the master copy of your website. Back it up like any important folder: an external drive, iCloud Drive, or a zip file.

- The site's files are also on GitHub once published.
- **Your private planning notes are not on GitHub**: `CONTEXT.md`, `COPY.md`, `DESIGN.md`, the brand kit and the full-size photos stay only in this folder, on purpose, because the GitHub repository is public. Losing this folder would lose them, so keep a backup.

## 7. What is in this folder

| Item | What it is |
| --- | --- |
| `Edit my website.command` | Opens the editor |
| `Publish to GitHub.command` | Sends the website online |
| `content/site.json` | Every word on the website. The editor changes this file for you |
| `site/` | The finished website: what visitors download |
| `editor/` | The editor itself |
| `src/`, `build.rb` | How the pages are put together (for Claude) |
| `fetch_fonts.rb` | Downloads the fonts again if a greeting changes (for Claude) |
| `vercel.json` | Tells Vercel how to serve the site |
| `HANDOVER.md` | Instructions for Claude |
| `CONTEXT.md`, `COPY.md`, `DESIGN.md` | Your private planning notes: facts, copy history and design rules (not published) |

The fonts are Bricolage Grotesque, Newsreader, IBM Plex Mono and Noto Sans, all under the SIL Open Font Licence; their licence texts are in `site/assets/fonts/licences/`.
