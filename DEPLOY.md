# Deploying via Vercel (Option A: build locally and commit)

Follow these steps to deploy the site from this repository using Vercel's web interface:

1. Build the web output locally

```bash
flutter build web --release
```

2. Add and commit the generated output

```bash
git add build/web
git commit -m "Add built web output for Vercel"
git push
```

3. On Vercel (when connecting the GitHub repo):
- Set the **Build Command** to empty (no command).
- Set the **Output Directory** to `/` (root), since `vercel.json` serves files from `build/web`.

Notes:
- We added `vercel.json` to use `@vercel/static` which serves the committed `build/web` files.
- `.gitignore` was adjusted to allow committing `build/web` while still ignoring other build output.

If you want, I can build and commit `build/web` for you here — but that requires Flutter to be installed and may take several minutes.
