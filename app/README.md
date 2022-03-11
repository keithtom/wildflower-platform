# App Folder

## Entry points to the app

- Channels: the entry point for websocket connections
- API Controllers: the entry point for HTTPS API calls
- Mailboxes: the entry point for SMTP (email interface)

## Backend Logic

- Commands: High-level business logic that gets called by the various entry points
- Services: API-like interfaces to the system representing models or abstract resources (e.g. chat, inbound_emails, nda, sessions). The most logic should be here.
- Jobs: Background workers
- Mailers: sending outbound emails
- Models: thin active record model layer
- Serializer: presenters for the models used primarily for the API & websocket channels
- Views: mailer views and legacy views
