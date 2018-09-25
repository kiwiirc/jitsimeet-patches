# Jitsi Meet KiwIRC patches

## About

This repository contains a set of patches to Jitsi Meet's Prosody plugins for use with [kiwiirc/plugin-conference]. The patches are necessary when using `{ "conference.secure": true }` in your KiwiIRC client config. You only need this if you want to self-host your own video/audio conference server for use with KiwiIRC. The patches are primarily adding functionality to mirror the access control model from the IRC channel to the XMPP conference room.

## Installation instructions

Jitsi Meet packaging may not be working with Ubuntu 18.04. It works for us on Ubuntu 16.04.

You must use an interactive shell when installing `jitsi-meet` because the packages will ask questions via debconf during installation and errors will occur if no debconf frontend is available.

### Basic Jitsi Meet install

In a terminal session:

```shell
# add Jitsi Meet repo and import apt signing key
echo 'deb https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list
wget -qO -  https://download.jitsi.org/jitsi-key.gpg.key | sudo apt-key add -

# add prosody-trunk repo and import apt signing key
echo deb http://packages.prosody.im/debian $(lsb_release -sc) main | sudo tee /etc/apt/sources.list.d/prosody-trunk.list
wget -qO - https://prosody.im/files/prosody-debian-packages.key | sudo apt-key add -

# install the packages
sudo apt-get update
sudo apt-get install nginx # must be installed *before* jitsi-meet
sudo apt-get install jitsi-meet jitsi-meet-tokens
```

### Jitsi Meet configuration

When you install the jitsi-meet packages, there will be an interactive question and answer session via debconf. Here are some examples of how you might answer those prompts:

#### Hostname

Example: `my-jitsi-meet-backend.192.168.1.220.xip.io`

#### SSL certificate for the Jitsi Meet instance

`"Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate)"`

#### The application ID to be used by token authentication plugin

Example: `192.168.1.220`

This **must** match the hostname in the upstream section of your webircgateway config **as well as** the server hostname that the *client* uses (i.e. `startupOptions.server` in the client `config.json`)

If it doesn't match, the token that's automatically acquired from the webircgateway via the EXTJWT command be rejected by the Prosody server and the conference will not work. When this is the problem, you will likely see an error like `[connection.js] <n.l>:  CONNECTION FAILED: connection.passwordRequired` in your browser console when attempting to create a conference.

#### The application secret to be used by token authentication plugin

Example: `verysecret`

This **must** match the secret set in your webircgateway config.

### Post-installation patching

Jitsi Meet's patches need to be manually applied every time `prosody` is installed or upgraded.

```shell
sudo patch -N /usr/lib/prosody/modules/mod_bosh.lua /usr/share/jitsi-meet/prosody-plugins/mod_bosh.lua.patch
```

And finally, we need to apply the KiwiIRC patches whenever `jitsi-meet-tokens` is installed or upgraded:

```shell
# FIXME git repo url/branch will change
git clone git@github.com:kiwiirc/plugin-conference-jitsimeet.git
cd plugin-conference-jitsimeet
git checkout jitsi-meet-patches
chmod +x patch_jitsi-meet-tokens_for_kiwi.sh
sudo ./patch_jitsi-meet-tokens_for_kiwi.sh
```

### Restart Prosody

After patching the Prosody plugins, you'll need to restart the `prosody` service before they take effect. Note that the service will be enabled *and* started automatically when you first install it.

```shell
sudo systemctl restart prosody.service
```

## References

Parts of the above instructions are summarized from [the Jitsi Meet docs] and [the Prosody docs]. See those links for more information. If you run into trouble, come by [#kiwiirc](ircs://chat.freenode.net:6697/#kiwiirc) on Freenode or open a github issue here.

[kiwiirc/plugin-conference]: https://github.com/kiwiirc/plugin-conference
[the Jitsi Meet docs]: https://github.com/jitsi/jitsi-meet/blob/master/doc/quick-install.md
[the Prosody docs]: https://prosody.im/download/package_repository
