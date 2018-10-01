# Jitsi Meet KiwiIRC patches

## About

This repository contains a set of patches to Jitsi Meet's Prosody plugins for use with [kiwiirc/plugin-conference].
The purpose of these patches is to mirror the access control model and user identity from the IRC environment to the Jitsi conference room.

The patches are necessary when using `{ "conference.secure": true }` in your KiwiIRC client config.

You will need to host your own Jitsi Meet server for secured KiwiIRC conference calls, as the patches will make the services incompatible with other public Jitsi servers.

## Prerequisites

Before proceeding, you'll need to complete the installation of the Jitsi Meet backend. Using the apt repository mentioned in [Jitsi Meet's instructions], install the `jitsi-meet` and `jitsi-meet-tokens` packages. e.g. `apt-get install jitsi-meet jitsi-meet-tokens`.

A few hints:

- `jitsi-meet-tokens` currently has a dependency on `prosody-trunk`, rather than the `prosody` package available in the main Ubuntu 16.04 repositories. See [Prosody's documentation] to add their apt repository as a package source on your system.
- The Jitsi Meet packaging may have issues on Ubuntu 18.04.
- Use an interactive shell when installing `jitsi-meet` because the packages will ask questions via debconf during installation and errors will occur if no debconf frontend is available.
- Install `nginx` **before** `jitsi-meet` if you want the `jitsi-meet` package to automatically create an nginx site configuration for you.

## Jitsi Meet configuration

The following configuration values will need special attention.

### Prosody conf.d site config

In `/etc/prosody/conf.d/<your jitsi domain>.cfg.lua`:

1. At the top level of the config, add these two lines, replacing `<your jitsi domain>` with the appropriate value for your installation:

```lua
jitsi_meet_domain = "<your jitsi domain>";
jitsi_meet_focus_hostname = "auth" .. jitsi_meet_domain;
```

2. `app_secret` (referred to as `application secret` during the interactive debconf prompts) needs to match the secret set in your webircgateway config.

3. `app_id` (`application ID` in debconf) must match the hostname in the upstream section of your webircgateway config **as well as** the server hostname that the KiwiIRC *client* uses (i.e. `startupOptions.server` in the client `config.json`)

4. Add `"muc_role_from_jwt"; "presence_identity";` to `modules_enabled` in the `"muc"` component.

5. Adjust the storage configuration based on your needs. Commenting out the default value in this config will work as shown below, but see the Jitsi docs for other options:

```lua
    -- storage = "null"
```

6. If you're hosting Jitsi on a separate hostname from KiwiIRC, you will need to either add

```lua
cross_domain_bosh = true;
```

at the top level of the config or manually add CORS headers in your nginx config.

### Jicofo SIP Communicator properties

7. Create or open `/etc/jitsi/jicofo/sip-communicator.properties` and add the following line:

```ini
org.jitsi.jicofo.DISABLE_AUTO_OWNER=True
```

### Jitsi Meet config

8. You may also want to disable P2P connectivity in the videobridge's config file at `/etc/jitsi/meet/<your jitsi domain>-config.js`.

```js
p2p: { enabled: false }
```

See `/usr/share/doc/jitsi-meet-web-config/config.js` for an example of the configuration format.

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
sudo systemctl restart prosody.service
```

[kiwiirc/plugin-conference]: https://github.com/kiwiirc/plugin-conference
[Jitsi Meet's instructions]: https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md
[Prosody's documentation]: https://prosody.im/download/package_repository
