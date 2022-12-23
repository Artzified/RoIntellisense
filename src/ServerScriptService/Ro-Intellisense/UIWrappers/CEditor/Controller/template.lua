return {
	identifier = 'template';
	priority = 1;

	label = 'helloworld';
	kind = Enum.CompletionItemKind.Snippet;
	documentation = {
		value = 'logs "hello world" to the console';
	};
	codeSample = [[print('hello world')]];
}