# Claude / Anthropic Serif (MB package)

Source: owner-provided `MB - Claude Font.zip` (Anthropic Serif Display + Text static OTFs).

Bundled into SLI Vault for primary UI typography at the project owner's request.
Keep the Downloads ZIP read-only; edit only copies under this folder.

## License status: UNVERIFIED - redistribution concern

No license file is included in this folder. These OTFs are not covered by the JetBrains Mono SIL OFL notice. Do not describe them as open-source fonts.

Findings from a public-source check on 2026-10-16:

- Anthropic Serif is described as a proprietary Anthropic brand typeface that is not offered for licensing.
- Copies of Anthropic fonts on third-party GitHub repositories state that they are for personal use only, that all rights remain with Anthropic, and that they are not covered by the repository's own license.
- Anthropic's separate OFL-licensed fonts (for example Work Sans in its public skills repository) are different fonts and do not grant any rights to Anthropic Serif.
- This folder's package name ("MB - Claude Font") is a third-party repackaging. No written permission from Anthropic is in the repository.

These findings are not legal advice and could not be confirmed against a first-party license. Treat the fonts as **not cleared for redistribution** until written permission or an official license is obtained.

The repository's root MIT license applies only to project-owned code and
documentation. It does **not** grant rights to these Anthropic Serif files.

## What this means for the project

- The files are registered in `pubspec.yaml` (families `Claude` and `ClaudeDisplay`) and are therefore compiled into every APK and AAB.
- 25 files in this folder are tracked in Git and were pushed to the private `origin` repository. Git history keeps them even if they are removed later.
- Do **not** make the GitHub repository **public**, publish a **public** GitHub Release, or upload an APK or AAB to Google Play while these files are in the tree or in history.
- A **private** repository pre-release APK (visible only to collaborators who can already clone the fonts) may be used for owner sideload testing. That does not clear redistribution for the public.
- Do not delete or replace these files as a side effect of cleanup. Replacement is a separate decision.

## Options (none applied)

1. Obtain written permission from Anthropic and add it to this folder.
2. Replace the family with an OFL-licensed serif and keep its license text beside it. Candidates: **Newsreader** (SIL OFL, has optical sizes like the current text and display cuts) or **Source Serif 4** (SIL OFL). Fonts must be bundled as files because the production app has no Internet permission.
3. If the repository must ever become public, rewrite history to remove the font binaries first. That is destructive and needs explicit approval.

JetBrains Mono, in `../jetbrains_mono/`, is under the SIL Open Font License 1.1 and keeps its `OFL.txt` beside it.
