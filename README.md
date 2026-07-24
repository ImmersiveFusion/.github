# .github

Organization-level GitHub configuration for **Immersive Fusion**.

## What is in here

| Path | What it does |
|---|---|
| `profile/README.md` | The **org profile page** rendered at [github.com/ImmersiveFusion](https://github.com/ImmersiveFusion). This is a public marketing surface, not internal docs. |
| `profile/.img/top.png` | The profile banner (with its `.psd` source). Read the guardrail below before touching it. |

## Before you edit `profile/README.md`

That page is public marketing copy and is governed like every other GTM surface.
Canon lives in `IF.Knowledge.Marketing/.context/current/`. The rules below are the
ones that have actually been broken here before:

- **The banner is a protected brand metaphor, not decoration.** `top.png` is the
  real-to-digital morph: a person resolving into their digital representation, which
  is the visual form of "Enter the World of Your Application®". The visored half is
  the digital representation, **not a VR headset**. The same image appears in the MSI
  installer chrome, so it cannot be changed here alone. See
  `marketing-canon/brand-metaphors.md`.
- **Statistics are governed by the KPI Freshness Policy**: 2-year age limit, retrieval
  date and source required, no Wayback fallbacks. Only cite what is in
  `messaging-standards.md` Approved Metrics. Two stale stats were removed from this
  page in July 2026, one of which had already been pulled from the storefront for the
  same reason and survived here.
- **The category is spatial observability.** Not "immersive observability", not "the
  next dimension of observability".
- **VR was dropped (2026-07-22).** The product is 3D desktop and web. Do not
  reintroduce headset language.
- **Product naming is IAPM** until the DeepCube trademark registers. No pre-rename.
- **No em dashes** (R-LOCAL-005).
- **Check every link.** A dead docs link (`Resources/Partner/Hall-of-Supporters`,
  deleted upstream) sat on the public profile until July 2026.

If a change here needs a claim, a price, a tier, or a product name, those are
Friday-owned facts. Render them, never invent them.