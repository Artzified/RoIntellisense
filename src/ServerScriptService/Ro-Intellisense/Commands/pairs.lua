return {
	identifier = 'pairs';
	priority = 1;

	label = 'for pairs';
	kind = Enum.CompletionItemKind.Snippet;
	documentation = {
		value = 'a pairs loop iterator';												
	};
	codeSample = [[for k, v in pairs() do
		
	end]];
}

