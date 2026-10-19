# Windows Dev Scratchpad — Description

## Why I keep this repository

Windows has a talent for taking a straightforward job and spreading it across an interface, three utilities and an obscure setting you last saw in 2019. PowerShell usually gets there quicker.

The starting point wasn't a grand plan for a Windows administration suite. It was repetition. I'd written a watcher, forgotten about it, written another, then done much the same thing with folder comparisons and quick diagnostics. Small scripts have a habit of disappearing precisely when you need them.

So I put them in one place.

This is my working collection of small Windows tools: file watchers, folder snapshots, a local HTTP server wrapper, hashing, log inspection, software inventories and a few related jobs. Some are wonderfully ordinary. That isn't a complaint. The boring utility that works is worth more to me than an elaborate tool that needs a manual simply to open.

## Why they remain small

I want to be able to open a script and understand what it'll touch before running it. More to the point, I want to stop it without dismantling an architecture.

Most of the numbered scripts work on their own. There's no shared runtime that every command must import, no compulsory background agent and no extra installation ritual. The local HTTP server uses Python because Python already has a perfectly serviceable basic server. The folder comparison wraps Robocopy instead of pretending I can outdo a long-established Windows utility in thirty lines.

The toolkit launcher is a concession to convenience, not an attempt to absorb everything. It locates selected tools in other TABARC-Code repositories and invokes them. Those tools remain separate projects, with their own responsibilities.

That's intentional. If the launcher breaks, the underlying scripts should still exist as things I can run directly.

## Privacy maintenance: what I actually wanted

The weekly cleaner came out of a familiar problem: Windows accumulates records of recently used files and other activity, and the various ways of tidying those records aren't particularly consistent.

But I don't buy the argument that every cache is suspicious or that deleting a system file must somehow make a computer cleaner. Prefetch helps Windows manage application launches. Saved Wi-Fi profiles exist because repeatedly entering network credentials is not an enjoyable hobby. USB device history helps Windows recognise devices.

The privacy-maintenance script therefore draws a line. It can clear current-user Recent shortcuts, request a Shell recent-use reset, and empty the current clipboard. Thumbnail-cache removal and a Windows API attempt at clearing non-pinned clipboard history are optional.

It doesn't remove original documents. It doesn't routinely delete Prefetch, wipe Wi-Fi profiles, scrub USB registry entries or destroy Jump List databases that may contain pinned items. The aim is ordinary housekeeping, not an implausible promise that nobody will ever be able to reconstruct past activity.

The same restraint explains the preview-first behaviour. Reading a report before allowing a command to delete something is hardly revolutionary. It simply saves trouble.

A separate script can register the cleaner as a weekly task in the current user's Windows session, or remove it again. It won't install itself just because somebody cloned the repository.

## The rebuild inventory

Reinstalling Windows is easier when you know what was on the machine before you wiped it. Easy enough to say; less entertaining when you're trying to remember which programme provided a particular driver, tool or obscure piece of software.

The rebuild script records installed application metadata, operating-system details, hardware basics and storage volumes. It can also export a WinGet package list. Its job ends there.

There is no automated restoration engine, no promise to recover personal files and no reason to mistake an inventory for a proper backup. The output is a plan for a human to check, not permission for a script to rebuild a computer without asking.

## Choices and compromises

PowerShell 5.1 compatibility matters because it's available on the Windows machines this collection is aimed at. PowerShell 7 is supported where the scripts and Windows APIs allow it. That's why the Windows CI workflow parses the repository in both environments and why fixture tests exercise the rebuild and privacy commands in both.

There are boundaries to that testing. Fixture folders can establish that preview mode doesn't delete a shortcut and that an applied run can clear a dummy thumbnail database. They cannot guarantee that Explorer will release its live cache, or that a scheduled clipboard-history call will work on every desktop session. Those operations are deliberately reported as best-effort.

The code also isn't a forensic cleaning suite, a full system-recovery environment, an enterprise device-management platform or a security product. It might develop in any of those directions later, but calling it one now wouldn't make it true.

I prefer the distinction between **implemented**, **tested** and **planned** to remain visible. There's a development plan in [`docs/WORKPLAN.md`](docs/WORKPLAN.md); it isn't a list of features secretly included in the latest release.

## Where it goes next

The obvious improvements are shared reporting, better error handling and a cleaner way to navigate the growing collection. I'd also like the standalone tools to cooperate without becoming dependent on one another: a useful system-change timeline, more reliable window-relative automation and controlled notifications for jobs that actually need attention.

No desperate rush to bolt a dashboard onto a file hash command.

The practical measure is still the same as when I wrote the first scratchpad script: does it save time, can I tell what it did, and can I trust it not to be clever at the expense of my data?

If the answer is yes, it earns its place.

---

**TABARC-Code**  
Windows PowerShell utilities, maintained as an independent collection.  
Licence: [MIT](LICENSE).
