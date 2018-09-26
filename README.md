# Jitsi Meet KiwiIRC patches

## About

This repository contains a set of patches to Jitsi Meet's Prosody plugins for use with [kiwiirc/plugin-conference].
The purpose of the patches is to mirror the access control model from the IRC channel to the XMPP conference room.
The patches are necessary when using `{ "conference.secure": true }` in your KiwiIRC client config.

## Prerequisites

Before proceeding, you'll need to complete the installation of the Jitsi Meet backend, including the optional `jitsi-meet-tokens` package. See [Jitsi Meet's instructions].

A few hints:

- As of September 2018, the `jitsi-meet-tokens` depends on `prosody-trunk`, rather than the `prosody` package available in the main Ubuntu 16.04 repositories. See [Prosody's documentation] for use of their apt repository.
- The Jitsi Meet packaging may have issues on Ubuntu 18.04.
- Use an interactive shell when installing `jitsi-meet` because the packages will ask questions via debconf during installation and errors will occur if no debconf frontend is available.
- Install `nginx` **before** `jitsi-meet` if you want the `jitsi-meet` package to automatically create an nginx site configuration for you.

## Jitsi Meet configuration

The `application secret` set in the prosody config needs to match the secret set in your webircgateway config.

The `application ID` in the prosody config must match the hostname in the upstream section of your webircgateway config **as well as** the server hostname that the KiwiIRC *client* uses (i.e. `startupOptions.server` in the client `config.json`)

## Post-installation patching

Finally, we need to apply the KiwiIRC patches from this repository whenever `jitsi-meet-tokens` is installed or upgraded:

```console
$ git clone --branch jitsi-meet-patches git@github.com:kiwiirc/plugin-conference-jitsimeet.git kiwiirc-jitsimeet-patches
Cloning into 'kiwiirc-jitsimeet-patches'...
remote: Enumerating objects: 271, done.
remote: Total 271 (delta 0), reused 0 (delta 0), pack-reused 271
Receiving objects: 100% (271/271), 418.22 KiB | 0 bytes/s, done.
Resolving deltas: 100% (34/34), done.
Checking connectivity... done.

$ cd kiwiirc-jitsimeet-patches

$ sudo ./patch_jitsi-meet-tokens_for_kiwi.sh
Kiwi patcher for Jitsi Meet Tokens

Applying kiwiirc-jitsi-meet-tokens.patch to /usr/share/jitsi-meet/prosody-plugins/
...
Done!
```

## Restart Prosody

After patching the Prosody plugins, you'll need to restart the `prosody` service before they take effect.

```console
$ sudo systemctl restart prosody.service
```

[kiwiirc/plugin-conference]: https://github.com/kiwiirc/plugin-conference
[Jitsi Meet's instructions]: https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md
[Prosody's documentation]: https://prosody.im/download/package_repository
