// Bundle the CLI into a single self-contained ESM file.
//
// Without bundling, the published osury package imports modules from
// @rescript/core, which in turn import runtime files from @rescript/runtime
// (rescript 12) or rescript/lib/es6 (rescript 11). @rescript/core@1.6.1 ships
// pre-compiled .mjs files that target the rescript 11 runtime layout, so a
// fresh `npm install osury` followed by `npx osury` fails with
// ERR_MODULE_NOT_FOUND on `rescript/lib/es6/caml_option.js`.
//
// Bundling inlines every @rescript/* import into the CLI binary, so the
// consumer needs ZERO ReScript-related packages at runtime — just Node.
//
// The bundle is the only artifact shipped to npm (package.json::files only
// contains `dist/` and README). Source .mjs files remain in `src/` for
// development and for the test suite, but are NOT published.

import { build } from "esbuild";

await build({
  entryPoints: ["bin/osury.mjs"],
  outfile: "dist/osury.mjs",
  bundle: true,
  platform: "node",
  format: "esm",
  target: "node18",
  // bin/osury.mjs already starts with `#!/usr/bin/env node` — esbuild
  // preserves the entry-file shebang in the bundle, so the output is
  // directly executable after npm chmod +x. Don't re-add via banner
  // (would produce a second shebang on line 2 → SyntaxError).
  external: [],
  // Minify is off by default — keeps the bundle inspectable post-install
  // and stack traces readable. Bundle is ~200 KB, not worth obscuring.
});

console.log("✓ Bundle written to dist/osury.mjs");
