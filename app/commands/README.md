# Commands

The commands folder should be high-level list of business actions that an outside facing user would do. The nouns and language should reflect business operations and not internal engineering concepts.

For example, a "user signup" is what most business users would say, they would not talk about lower level actions like "user create and generate token".

Commands generally should pull in logic from models, controllers or any external API.
They should make heavy use of services as "internal APIs".

As a convention, the `#call` method should be made up of private methods and provide a high level language to explain what the command is doing.
