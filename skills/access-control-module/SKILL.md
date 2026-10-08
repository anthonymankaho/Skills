---
name: access-control-module
description: Use when adding a login/permission gate to a standalone single-file HTML+localStorage tool, or to a hub launcher that opens several such tools - covers the account/session data model, the master-account bootstrap, per-tab or per-tile permission gating, the seed-promotion redeploy step, and deciding which single layer should own the gate when a hub launches embedded tool files.
---

# Access Control Module (Static HTML Tools)

## Overview

A reusable workflow-level login/permission gate for standalone, backend-less
HTML+JS+localStorage tools (no server, no real security - a technically able
user can bypass it via devtools/localStorage). Its job: keep casual users on
the modules assigned to them and record who's using the tool. One fixed data
model (master account + editable accounts list + session) plus a permission
map that can key off ANYTHING selectably-hideable - tabs inside one file, or
tiles/tools inside a hub launcher.

## When to Use

- Adding "who can see what" to any new standalone HTML tool in the Meyer/MPL
  suite (MPL_Property_Register.html, MPL_Combined.html, future tools)
- A tool has multiple tabs/sections, or a hub page launches multiple embedded
  tool files (tiles -> iframes), and different staff should only see some
- Deciding WHERE the login/gate should live when there's more than one
  plausible boundary (a hub launcher AND the individual tool files it
  launches) - see "One gate per boundary" below, the costliest judgment call
  in this whole pattern
- Exporting/redeploying local account edits so a colleague on a different
  machine/browser sees them (localStorage never syncs - not across machines,
  not across GitHub Pages visitors)

## One gate per boundary - decide this BEFORE writing code

If a hub launcher (e.g. MPL_Combined.html) embeds/launches several independent
tool files, put the ONE real gate at the hub level, keyed by which tile/tool
each account can open. Do NOT also build a second, duplicate gate inside each
embedded tool file - that means logging in twice for the same boundary, and
confuses "which login is the real one" for both builder and user.

If a single tool file has multiple internal tabs/views with no separate hub
above it, the gate belongs inside that file, keyed by tab.

**Get this wrong and you build the whole module in the wrong place** - this
happened on 2026-09-29: "how many sub-modules" was heard as "the 4 tabs inside
MPL_Property_Register.html" when the user meant "the 4 top-level tiles inside
MPL_Combined.html, one of which happens to BE that file". A full tested module
was built, then had to be stripped back out of the tool file and rebuilt at
the hub. Before writing any code, confirm out loud which physical units (tabs
in ONE file, vs. separate top-level files/tiles) the requested "N modules"
actually refers to.

## Core Pattern

Data model - one hardcoded master account (works on a fresh copy of the file
with zero setup) + an editable accounts list following the same seed-once
pattern already used for every other data type in these tools:

```js
const MASTER_ACCOUNT = {
  username: 'MPL', password: 'MPL',
  permissions: { unitA:true, unitB:true, unitC:true, unitD:true }, // one key per gated unit
  enabled: true, isMaster: true
};
const SEED_ACCOUNTS = [];                          // promoted here on redeploy, see below
const ACCOUNTS_SEED_FLAG_KEY = 'xxx_accounts_seed_v1_done';
const SESSION_KEY = 'xxx_current_session';

function findAccountByUsername(username){
  const uname = String(username||'').trim().toLowerCase();
  if (!uname) return null;
  if (MASTER_ACCOUNT.username.toLowerCase() === uname) return MASTER_ACCOUNT;
  return loadList('accounts').find(a => (a.username||'').toLowerCase() === uname) || null;
}
function attemptLogin(username, password){
  const account = findAccountByUsername(username);
  if (!account) return {success:false, error:'Unknown username.'};
  if (!account.enabled) return {success:false, error:'This account has been disabled.'};
  if (account.password !== password) return {success:false, error:'Incorrect password.'};
  return {success:true, account};
}
```

Session is just a username string in localStorage (`getCurrentSession` /
`setCurrentSession` / `clearCurrentSession`) - no token, no expiry, matching
the workflow-gate (not real security) positioning.

Visibility is one permission-map-driven function, generic over WHAT is being
shown/hidden (tab buttons, tile divs, iframe-launcher tiles - anything
addressable by a `<prefix>-<unitKey>` id convention):

```js
const PERMISSION_MAP = { unitA: 'permKeyA', unitB: 'permKeyB' /* ... */ };
function applyVisibility(account){
  const perms = account ? account.permissions : {};
  let firstPermitted = null;
  Object.keys(PERMISSION_MAP).forEach(unitKey => {
    const node = document.getElementById('unit-' + unitKey);
    if (!node) return;
    const allowed = !!perms[PERMISSION_MAP[unitKey]];
    node.classList.toggle('hidden', !allowed);
    if (allowed && !firstPermitted) firstPermitted = unitKey;
  });
  // fall back to a "no modules assigned" message if firstPermitted stays null
}
```

Master account (`isMaster: true`) always additionally sees a hidden-by-default
"Access Control" admin unit; every other account never sees it.

Admin UI (master-only): a table of accounts with one checkbox per permission +
Enabled, a Save button per row, a New Account form, and an Export button.

## Seed-promotion for redeploy (localStorage doesn't sync)

Same idempotent seed-once-then-editable pattern as every other data type in
these tools (properties, lease records, etc.): `SEED_ACCOUNTS` starts empty,
`seedAccountsIfNeeded()` loads it into `localStorage` once (flagged so it
never re-seeds over local edits), and accounts created/edited locally stay
LOCAL until exported and pasted back into the file's own `SEED_ACCOUNTS`
constant:

```js
function exportAccountsSnippet(){
  const accounts = loadList('accounts');
  const json = JSON.stringify(accounts).replace(/<\/script/gi, '<\\/script'); // see Gotcha 2
  download(`SEED_ACCOUNTS_export_${new Date().toISOString().slice(0,10)}.js`,
    'const SEED_ACCOUNTS = ' + json + ';');
}
```

This snippet gets pasted back into the file's own source and the file
redeployed (e.g. GitHub Pages) - this is the ONLY way a colleague opening the
file fresh on a different machine ever sees an account that was created
locally.

## Optional: "Forgot Password" (direct reveal - no email, no third party)

Default choice: on the login screen, a "Forgot password?" link asks for a
username only; on submit, look up the account and show its (plaintext)
password directly on screen. No email field, no external service, no
deployment step - consistent with, not a bigger risk than, the rest of this
module's already-accepted "workflow gate, not real security" positioning
(a valid username alone reveals that account's password, same order of
exposure as the plaintext-password-in-localStorage risk already accepted
everywhere else here):

```js
function onForgotPasswordSubmit(){
  const account = findAccountByUsername(el('forgot-username').value);
  if (!account || account.isMaster){
    return showForgotResult(false, 'Unknown username - contact the MPL admin.');
  }
  if (!account.enabled){
    return showForgotResult(false, 'This account has been disabled - contact the MPL admin.');
  }
  showForgotResult(true, 'Your password is: ' + account.password);
}
```

The master account (`MASTER_ACCOUNT`) is a hardcoded constant, not a stored
record, and is deliberately excluded (same "contact the admin" message,
rather than either erroring or - pointlessly - revealing a password that's
already documented everywhere this module's design is discussed).

**Alternative (more moving parts, only worth it for an audit trail or actual
email notification): route through EmailJS instead of revealing on-screen.**
Add an `email` field to each account record and call
`emailjs.send(serviceId, templateId, {to_email, to_username, to_password})`
(`@emailjs/browser` CDN script + `emailjs.init({publicKey})`) instead of
`showForgotResult` directly. If you go this route, treat the EmailJS Public
Key as a materially bigger risk than the rest of this module's accepted
"no real security" stance (it's *designed* to sit in client-side code, but
it's still a live credential anyone reading the page source can call) - lock
the key's allowed origins on the EmailJS dashboard to the real deployed
domain, never `*`, and give the template a single fixed subject/body shape
so a caller can't send arbitrary content through your account. Call this
out explicitly to whoever approves the design, separately from the rest of
this module's already-accepted risk. This session churned through EmailJS ->
a Cloudflare Worker (an even-more-secure but heavier option, credential kept
server-side) -> back to direct-reveal before landing here - see Real-world
case below; don't assume whichever one sounds best on paper is the one
that'll actually get deployed.

## Gotchas (all found by review, not caught by the existing Node-stub test convention)

1. **An account-row checkbox `id` built from the username must use plain
   HTML-attribute escaping (`escHtml`), never JS-string-literal escaping
   (`escJsAttr`), even though that SAME row's `onclick="saveAccountRow('...')"`
   argument correctly uses `escJsAttr`.** These are different escaping
   contexts and are not interchangeable: `escJsAttr` additionally
   backslash-escapes quotes for safety inside a single-quoted JS string
   literal (correct for the onclick argument), but a checkbox `id` is plain
   HTML, looked up later via plain string concatenation (`'perm-x-' +
   username`, no un-escaping step) - the extra backslash makes the rendered id
   diverge from the lookup id for any username containing an apostrophe (e.g.
   "O'Brien"), so Save silently finds nothing and does nothing. No error, no
   console warning - just a button that appears to work and doesn't. Verify
   with a real apostrophe-containing username, not just an alphanumeric one.

2. **The exported/promoted `SEED_ACCOUNTS` snippet must neutralize a literal
   `</script` sequence before being embedded back into the file**, or a
   username/password containing it prematurely closes the surrounding
   `<script>` block when pasted back in - the HTML parser looks for that exact
   byte sequence before any JS parsing happens, so this corrupts the file
   regardless of JS string-escaping. `.replace(/<\/script/gi, '<\\/script')`
   on the JSON string, same fix as the single-file HTML-report combiner in
   the `excel-to-interactive-html-report` skill. This is easy to reintroduce
   even while fixing something else: an explanatory code comment describing
   this exact bug, if it contains the literal sequence `</script` itself
   (rather than the escaped form), breaks the file identically to the bug
   it's documenting - a self-inflicted repeat of the same failure, caught only
   because the file failed to parse at all. Never type the raw sequence
   `</script` anywhere in this file, including inside comments about it.

3. **Toggling a currently-logged-in account's own "Enabled" checkbox off must
   force an immediate logout, not just re-render the admin list.** Without
   this, the point of the Enabled toggle - immediately curtailing access -
   silently doesn't hold for the one account actively testing it; the change
   only takes effect on that user's next reload, which for a shared machine or
   an admin doing hands-on QA is not "immediate" at all. Check
   `getCurrentSession()` against the row being saved and call `logout()` if it
   now reads `enabled:false`.

4. **A not-yet-built module (e.g. an "Accounting" tile with no linked tool
   yet) and an externally-linked module (e.g. a "Payment Requisition" tile
   that's a plain `<a href>` to another system, not an embedded iframe) still
   each need a permission key in the map**, even though neither can be
   meaningfully "opened" the same way as a local iframed tool - gate them
   anyway (disabled-regardless-of-permission for the unbuilt one;
   permission-gated same as any other tile for the external-link one) rather
   than special-casing them out of the permission model, so the admin UI stays
   one consistent table instead of a table-plus-footnotes.

## Testing approach

Same convention as every other feature in these tools: extract the `<script>`
block, `node --check` for syntax, hand-written Node-stub tests (a `store`
object backing `localStorage`, `elCache` backing `getElementById`) for the
account/session/permission logic, then a real jsdom pass (`url:
'http://localhost/...'`, NOT `file://` - that throws under an opaque origin
for `localStorage`; `runScripts:'dangerously'`) exercising an actual
apostrophe-username end-to-end, since Gotcha 1 specifically only surfaces with
real DOM id lookups, not plain-function unit tests.

## Real-world case

Built for MPL_Property_Register.html (2026-09-29) keyed by its 4 internal tabs
(Properties/NCA & Depreciation/Impairment Test/Lease Status) plus a
master-only Access Control tab; a same-day self-review (after two background
subagent review dispatches were lost to session restarts) found Gotchas 1-3
above, each confirmed failing first, then fixed and re-verified with a full
regression pass. Immediately after, the user corrected the boundary: the real
"4 sub-modules" were the 4 top-level tiles of the hub launcher
MPL_Combined.html (MPL Accounting, MPL Property Management, MPL Debit/Credit
Note, MPL Payment Requisition - an external FINSYS link), not this file's own
tabs - triggering "One gate per boundary" above.

Rebuilt one level up the same day (2026-09-30): the tab-level gate was
stripped entirely out of MPL_Property_Register.html (it now has no access
control of its own - opening it directly shows the app immediately), and the
same pattern was rebuilt keyed to MPL_Combined.html's 4 tiles instead, plus
the optional email/Forgot-Password addition above. Gotcha 2 (the
`</script`-in-a-comment meta-bug) recurred verbatim in the new code's own
explanatory comment during this rebuild - caught immediately by the same
"jsdom fails to parse the file at all" signal, confirming this specific
mistake is a genuine recurring trap worth its own named gotcha, not a
one-off. `payload-propreg` (the hub's embedded snapshot of
MPL_Property_Register.html) also needed regenerating after the tab-gate
removal - located by its `id="payload-propreg"` marker, never a hardcoded
line number, and round-trip-verified byte-for-byte before the one-off
rebuild script was deleted.

**Forgot-Password mechanism churned three times before landing on direct
reveal** - worth remembering as a sequencing lesson, not just a technical
one: EmailJS was the first choice, then switched to a Cloudflare Worker once
the user mentioned having a Cloudflare account (a Worker keeps the real send
credential server-side, a genuinely better security posture), which in turn
surfaced that the project's existing Gmail OAuth automation looked reusable
but wasn't (it's deliberately drafts-only and its refresh token is
Windows-DPAPI-encrypted/machine-bound) - then the user cancelled the Worker
plan entirely and asked to go back to EmailJS - then, one turn later, asked
to drop email entirely and just reveal the password directly once a correct
username is entered, which is what actually shipped. Net effect: real
implementation effort was spent (Worker fetch()-call wiring, Gmail-reuse
investigation, then a full EmailJS integration) on two paths that were both
reverted before being finished, and the final shipped design turned out to
be the *simplest* one available, not the most elaborate. **Lesson: for a
component with a real security trade-off (who holds the send credential, and
how), get the infrastructure decision confirmed as settled before writing
integration code against it** - not just "which one sounds better," since
better-on-paper doesn't mean the user has decided to actually go deploy it,
and it's worth periodically asking whether the simplest option (here:
skipping email/third-parties entirely) was considered at all before
building something heavier.
