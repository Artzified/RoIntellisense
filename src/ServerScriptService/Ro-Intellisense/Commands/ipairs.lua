return {
	identifier = 'ipairs';
	priority = 1;

	label = 'foripairs';
	kind = Enum.CompletionItemKind.Snippet;
	documentation = {
		value = 'a ipairs loop iterator';												
	};
	codeSample = [[for i, v in ipairs() do
		
	end]];
}

