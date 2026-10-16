<!-- LOVABLE:BEGIN -->

> [!IMPORTANT]
> This project is connected to [Lovable](https://lovable.dev). Avoid rewriting
> published git history — force pushing, or rebasing/amending/squashing commits
> that are already pushed — as it rewrites history on Lovable's side and the
> user will likely lose their project history.
>
> Commits you push to the connected branch sync back to Lovable and show up in
> the editor, so keep the branch in a working state.

<!-- LOVABLE:END -->

- Preserve the TanStack Start bootstrap and pinned target dependencies; adapt imported presentation modules instead of replacing runtime infrastructure.
- Keep screenshot and project-destination data in one browser-safe module; reusable phone frames and the Radix lightbox consume this mapping.
- Render the screenshot gallery as a responsive CSS grid using the shared mapping and existing Radix lightbox; this keeps previews readable without horizontal scrolling.
- Serve uploaded media and locally supplied fonts through asset pointers; keep the brand-derived favicon as a real public image.
- Keep the showcase static and prerender the public index; it requires no authentication, data service or analytics.
- Preserve the standalone static export script as a local-only tool so portable exports do not enter the server runtime.
