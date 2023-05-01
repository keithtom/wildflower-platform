# WIP

This should all be renamed to `Business` to store business actions.

# Commands

The commands folder should be high-level list of business actions that an outside facing user would do. The nouns and language should reflect business operations and not internal engineering concepts.

For example, a "user signup" is what most business users would say, they would not talk about lower level actions like "user create and generate token".

Commands generally should pull in logic from models, controllers or any external API.
They should make heavy use of services as "internal APIs".

As a convention, the `#call` method should be made up of private methods and provide a high level language to explain what the command is doing.


# Services

Services are plain ruby objects.
They inherit from BaseService which provides some helpers.

These act as programmer APIs to our internal resources.
They should be called from commands or other services.
Lower level objets like models should never call services.

When raising an exception inside a service, simply raise an `Error` object. This will be scoped to the service name; e.g. `MyService::Error`.
When catching exceptions, it is better to catch the more specific error like `MyService::Error`. And if needed, raise more specific error types.
_IMPORTANT_: Make sure your services are atomic.
