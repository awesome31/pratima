# Pratima Jain: personal website

A five-page static site: Home, About, Ideas & experiments, Speaking & teaching, Contact. Plain HTML, CSS and a little JavaScript. No framework and no third-party embeds.

## What's here

| Path | What it is |
| --- | --- |
| `site/` | The finished website. This folder is what gets served. |
| `src/` | Page templates (`src/pages/*.erb`) and the shared layout (`src/layout.erb`). |
| `build.rb` | Turns the templates into the pages in `site/`. Also holds the shared pieces: drawings, marks, lists. |
| `fetch_fonts.rb` | Downloads the fonts into `site/assets/fonts/` so the site makes no requests to Google. |
| `vercel.json` | Tells Vercel to serve `site/` as it is, with no build step. |

Styles are in `site/assets/css/site.css` and behaviour in `site/assets/js/site.js`; both are edited directly.

## Changing the site

1. Edit a template in `src/`, or the styles or script in `site/assets/`.
2. Rebuild the pages:

   ```bash
   ruby build.rb
   ```

3. Look at it locally:

   ```bash
   ruby -run -e httpd site -p 4173
   ```

   Then open http://localhost:4173.

Ruby is the only tool needed, and macOS ships with it.

## Publishing

Vercel deploys this repository automatically. `site/` is committed already built, so Vercel runs no build of its own. Pushing to `main` updates the live site; pushing to any other branch creates a preview.

## Fonts

Bricolage Grotesque, Newsreader, IBM Plex Mono and four Noto Sans script fonts, all under the SIL Open Font Licence. Licence texts are in `site/assets/fonts/licences/`. The script fonts contain only the letters of the greetings on the site; run `ruby fetch_fonts.rb` again if a greeting changes.

## Contact form

The form on the Contact page sends to a Google Form. Its link is set at the top of `build.rb`.
