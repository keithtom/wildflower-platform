# Services

Services are plain ruby objects.
They inherit from BaseService which provides some helpers.

These act as programmer APIs to our internal resources.
They should be called from commands or other services.
Lower level objets like models should never call services.

When raising an exception inside a service, simply raise an `Error` object. This will be scoped to the service name; e.g. `MyService::Error`.
When catching exceptions, it is better to catch the more specific error like `MyService::Error`. And if needed, raise more specific error types.
_IMPORTANT_: Make sure your services are atomic.
