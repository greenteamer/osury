export default {
  testEnvironment: 'node',
  transform: {},
  moduleFileExtensions: ['js', 'mjs'],
  testMatch: ['**/*.test.mjs'],
  // @rescript/core@1.6.1 ships JS compiled against the ReScript 11 runtime
  // (rescript/lib/es6/*); ReScript 12 moved it to @rescript/runtime. Without
  // this the suite only passes on a node_modules that happens to keep stale
  // ReScript 11 files — a clean `npm ci` (and so `prepublishOnly`) fails.
  // Same alias as demo/vite.config.js.
  moduleNameMapper: {
    '^rescript/lib/es6/caml_option\\.js$': '<rootDir>/node_modules/@rescript/runtime/lib/es6/Primitive_option.js',
  },
}
