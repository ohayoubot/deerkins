# deerkins

## Requirements

Node 18 or newer and a Cloudflare account.

## Local

```sh
pnpm install
pnpm run db:init  # create the schema
pnpm run db:seed  # load seed.sql
pnpm run dev      # http://localhost:8788/deerkins/
pnpm test
pnpm lint         # biome; `pnpm lint:fix` writes the fixes
```

`seed.sql` contains the original 1600+ deerkins/artbutt works from yore.

## Deploy

Create the two databases once and put the ids they print into `wrangler.toml`.
Production is bound at the top level; `deerkins-preview` is bound under
`[[env.preview.d1_databases]]` so preview deployments never touch production
data:

```sh
pnpm exec wrangler d1 create deerkins
pnpm exec wrangler d1 create deerkins-preview
```

If wrangler token is expired run:

```sh
pnpm exec wrangler login
```

Then:

```sh
pnpm run db:init:remote
pnpm run db:seed:remote  # might take a few minutes
pnpm run deploy
openssl rand -hex 32 | pnpm exec wrangler pages secret put IP_SALT --project-name deerkins
pnpm run deploy
```

- The first `deploy` is what creates the Pages project.
- The second `deploy` applies the `IP_SALT` env variable

`IP_SALT` salts the hashed client IPs used for rate limiting. This means they
are *anonymized*. You can inspect the code yourself!

## Preview deployments

Cloudflare's GitHub integration builds a preview deployment for every push to a
non-production branch on the host repo (NOT from forks).

Give the preview database its schema, otherwise preview builds serve a working
site backed by empty tables:

```sh
pnpm run db:init:preview
pnpm run db:seed:preview  # optional, only if you want real data to click around
```

`wrangler pages secret put` writes to Production only. Preview needs its own
`IP_SALT`, set in the dashboard under the project, Settings, Variables and
secrets, Preview. Use a different value than production so the two environments
cannot produce matching IP hashes.

Two dashboard settings worth turning on, neither of which lives in this repo:

- Settings, General, *Enable access policy*. Preview URLs are public by default
  and stay reachable forever once created. This limits them to account members.
  It does not cover the `pages.dev` domain or the custom domain.
- Settings, Builds and deployments, preview branch control. Defaults to every
  non-production branch. Narrow it to the branch prefixes you actually use, or
  set it to None to build only on merge.

Prefix a commit message with `[CI Skip]` or `[CF-Pages-Skip]` to skip one build.

## Domain

Add the domain in the Cloudflare dashboard under Workers & Pages, the deerkins
project, Custom domains. Cloudflare writes the DNS record itself if the zone is
already in the same account. Adding a zone to Cloudflare does not attach it to
the project. This is a separate step.

The project serves everything. The app is the `deerkins` subdirectory of
`public`, so it ends up at `<domain>/deerkins/`.

## Checks after deploying

Under project settings, confirm `IP_SALT` is listed under Production and not
only Preview, that the Production `DB` binding points at `deerkins`, and that
the Preview `DB` binding points at `deerkins-preview`. If Preview still shows
`deerkins`, a branch build can write to production data.

Per-deployment preview URLs return 404 for `/deerkins/api/*`. The production
domain serves it. Test against the production domain.
