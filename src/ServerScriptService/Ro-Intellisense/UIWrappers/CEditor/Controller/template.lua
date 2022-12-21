return {
	identifier = 'template'; 						 -- unique command identifier
	priority = 1; 									 -- autocomplete priority

	label = 'helloworld'; 							 -- autocomplete label
	kind = Enum.CompletionItemKind.Snippet; 		 -- autocomplete icon
	documentation = {
		value = 'logs "hello world" to the console'; -- documentation							
	};
	codeSample = [[print('hello world')]];			 -- code to replace
}