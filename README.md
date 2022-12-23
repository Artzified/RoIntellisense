# RoIntellisense

RoIntellisense is a highly useful tool for Roblox developers, as it helps to streamline the coding process by providing more customizable and comprehensive autocomplete suggestions. In just a few clicks, RoIntellisense helps you to produce the same string of code with little to no effort! This can save you significant time and help you write faster, and more efficient!

In addition to providing customizable autocomplete functionality, RoIntellisense also offers other helpful features such as comment dividers. These features will help you organize your code in just a few clicks!

Overall, RoIntellisense is a valuable addition to any Roblox developer's toolkit, and we highly recommend giving it a try. Whether you're a seasoned pro or just starting with Roblox development, RoIntellisense can help you write better code more efficiently.

## Installation

https://www.roblox.com/library/10029678299/Ro-Intellisense

## Usage

- Install the [plugin](#Installation)
- Head over to the plugins tab
- Activate RoIntellisense by clicking the Ro-Intellisense button

In order to use the RoIntellisense Command Editor:
- Open the command editor by clicking the Commands Editor button
- Select/create a command you want to edit
- Edit the command properties, as your heart desires. See [Documentation](#Documentation) for further details.

## Documentation

### Functions

Format:
```lua
--[[
  description

  @param type arg description
  
  @return type description
]]
function func()

end
```

Note: Anything that is not prefixed with @ will be considered part of the description. If the @param tag is incomplete (e.g. @param type arg), it will be ignored.

- __Tag__: param
- __Strict__: Yes
- __Required__: No
- __Description__: The parameter.

#

- __Tag__: return
- __Strict__: No
- __Required__: No
- __Description__: What the function returns.

### Command Editor

Format:
```lua
return {
	identifier = 'template';
	priority = 1;

	label = 'test';
	kind = Enum.CompletionItemKind.Snippet;
	documentation = {
		value = 'a test command';					
	};
	codeSample = [[print('test')]];
	exclusiveTo = {};
}
```

- __Property__: `identifier`
- __Type__: string
- __Optional__: Yes
- __Description__: An unique identifier to the command, having 2 same identifier may cause a duplication bug.

#

- __Property__: `priority`
- __Type__: number
- __Optional__: No
- __Description__: Defines the command's priority, the higher it is, the higher it is in the autocomplete list.

#

- __Property__: `label`
- __Type__: string
- __Optional__: Yes
- __Description__: Defines the command's label, shown on the autocomplete list.

#

- __Property__: `kind`
- __Type__: Enum.CompletionItemKind
- __Optional__: No
- __Description__: Defines the command's kind, shown on the autocomplete list as the icon.

#

- __Property__: `documentation`
- __Type__: table
- __Optional__: No
- __Description__: Defines the command's documentation, shown on the autocomplete details.

#

- __Property__: `documentation.value`
- __Type__: string
- __Optional__: No
- __Description__: An element in the documentation property.

#

- __Property__: `codeSample`
- __Type__: string
- __Optional__: Yes
- __Description__: Defines the command's codeSample, shown on the autocomplete details and acts as the replacement code.

#

- __Property__: `exclusiveTo`
- __Type__: table
- __Optional__: No
- __Description__: The command will only register if the current placeId is inside the property.

## Contributing
We welcome and encourage contributions to RoIntellisense! Here are some guidelines to follow:

- Fork the repository and create a new branch for your changes.
- Make your changes, including relevant documentation.
- Create a pull request from your fork to the main repository.

The repository maintainers will review your pull request and may request changes or merge it.
Thank you for your contribution!

## Code of Conduct
We expect all contributors to adhere to our [Code of Conduct](CODE-OF-CONDUCT.md). Please make sure to read and understand it before contributing.

## License
By contributing to RoIntellisense, you agree that your contributions will be licensed under the [LICENSE](LICENSE) file in the root directory of this repository.

## Support me
If you would like to support my work, you can do so by making a [donation](https://www.roblox.com/games/10031431160/Artzified-Plugin-Donation-Center). Any amount is appreciated and helps me continue doing what I love. Thank you.