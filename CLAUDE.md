# pi-patch

Patches for @earendil-works/pi-coding-agent v0.74.0 that modify the Anthropic OAuth2 provider to route API requests through Claude Max subscription billing.

## What the patches do

1. `anthropic-provider.patch`: Adds billing attribution header (fingerprint), updates the user agent string, and merges the system prompt into a single text block. The single block structure is required; the Anthropic API routes multi-block system prompts to extra usage billing.
2. `oauth-url.patch`: Updates the OAuth authorize URL from `claude.ai/oauth/authorize` to `claude.com/cai/oauth/authorize`.
3. `disable-warning.patch`: Removes the "Third-party harness usage draws from extra usage" warning banner in interactive mode.

## Verify

```sh
shellcheck apply.sh revert.sh
./apply.sh
echo "hello" | pi --print
```
