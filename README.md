# Gmail OAuth2 Script

Script to get OAuth2 Access Token for Gmail.

It can be used with cli tools that interacts with Gmail via
[IMAP](https://tools.ietf.org/html/rfc3501) or [SMTP](https://tools.ietf.org/html/rfc5321).
For example:

- [`mutt`](http://www.mutt.org/) or [`neomutt`](https://neomutt.org/)
- [`mbsync`](https://isync.sourceforge.io/)
- [`msmtp`](https://marlam.de/msmtp/)
- Your own script/tool that speaks IMAP/SMTP

## Installation

Just copy the script you want on your machine and give it executable permission:

```sh
curl --progress-bar https://raw.githubusercontent.com/MunifTanjim/gmail-oauth2-script/main/gmail-oauth2_none_none.sh -o ~/.local/bin/gmail-oauth2.sh
chmod u+x ~/.local/bin/gmail-oauth2.sh
```

## Variants

There are several variants of the script using different tools for cache, storage or secret management.

### `gmail-oauth2_none_none.sh`

Minimal script with no extra features for caching or secret management.
It requires hardcoding sensitive information to the script.

#### Dependencies

- `bash`
- `jq`

#### Usage

**Get Refresh Token**:

```sh
gmail-oauth2.sh refresh_token --client-id CLIENT_ID --client-secret CLIENT_SECRET
```

**Get Access Token**:

```sh
gmail-oauth2.sh access_token --client-id CLIENT_ID --client-secret CLIENT_SECRET --refresh-token REFRESH_TOKEN
```

### `gmail-oauth2_bitwarden_secret-tool.sh`

Uses Bitwarden during initial setup and GNOME Keyring for the rest.

Store your OAuth2 Client's credentials in a Bitwarden item with the following custom fields:

- `client_id` - OAuth2 Client ID
- `client_secret` - OAuth2 Client Secret

#### Dependencies

- `bash`
- `jq`
- `bw` - [Bitwarden CLI](https://github.com/bitwarden/cli)
- `secret-tool` - CLI for GNOME Keyring

#### Usage

```sh
gmail-oauth2.sh <COMMAND> [ACCOUNT_ID]

Commands:
  authorize      Perform the initial authorization steps
  access_token   Prints Access Token

Flags:
  --account-id   Alias for the Gmail Account         (e.g.: "personal" or "me@example.com")
  --store-id     Description for GNOME Keyring Items (default: "Gmail-OAuth2-Script")
  --secret-id    Search Term for Bitwarden Item      (default: "client.oauth2.com.google.mail")
```

**Initial Authorization**:

Reads the `client_id` and `client_secret` from Bitwarden, stores them in GNOME Keyring.
Obtains a `refresh_token` after successful authorization and stores it in GNOME Keyring.

```sh
gmail-oauth2.sh authorize me@example.com
# or
gmail-oauth2.sh authorize --account-id me@example.com
```

**Get Access Token**:

Checks GNOME Keyring for existing `access_token`, if it's not expired prints it.
Otherwise, get an `access_token` using the `client_id`, `client_secret`, `refresh_token` from GNOME Keyring,
stores it in GNOME Keyring and prints it.

```sh
gmail-oauth2.sh access_token --account-id me@example.com
```

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.
