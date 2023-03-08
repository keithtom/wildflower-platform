# Render

Render is a similar platform to Heroku but is cheaper in general.
We still use Heroku for its low cost add-ons.

## Install CLI

```shell
brew tap render-oss/render
brew install render
```


## Configure SSH Keys

Generate an Ed25519 key.  This is required because it is [more secure than RSA](https://render.com/docs/ssh-troubleshooting#avoid-rsa-keys).
```shell
ssh-keygen -t ed25519 -f ~/.ssh/render
```

Go to your [Render Dashboard](https://dashboard.render.com/), under your profile Account Settings, go to `SSH Public Keys`.

Add the public key by copy pasting the contents of:
```shell
cat ~/.ssh/render.pub
```



## SSH Access

Every service will have a unique SSH user that you can view on that services `shell` page.



## Additional Reading

- [Render CLI](https://render.com/docs/cli)
- [Render SSH Keys](https://render.com/docs/ssh-generating-keys)
