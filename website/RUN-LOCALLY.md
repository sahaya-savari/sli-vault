# Run Streak's website on your PC (Windows)

1. Install Node.js 22 LTS from https://nodejs.org (this also installs npm).
2. Unzip this folder, open it in a terminal (PowerShell), then run:

       npm ci
       npm run dev

3. Open http://localhost:8080/streak/ in your browser. It reloads when you edit a file.

Where things are:
- Home page ........ src/index.njk
- Layout/head/nav .. src/_includes/base.njk
- Styles ........... src/css/styles.css
- JavaScript ....... src/js/site.js
- Phone images ..... src/assets/phones/

This is Streak's own site (GPLv3 with additional terms, see the Streak repo). Use it to study how it works.
Do not publish it as your own, and do not reuse its text or images on your website.
