local LSP = require'lux.lsp'

return {
  workspace = {
    applyEdit = true;
    workspaceEdit = {
      documentChanges = true;
      resourceOperations = {};
      failureHandling = 'abort';
    };
    didChangeConfiguration = {
      dynamicRegistration = false
    };
    didChangeWatchedFiles = {
      dynamicRegistration = false
    };
    symbol = {
      dynamicRegistration = false;
      valueSet = vim.tbl_values(LSP.SymbolKind);
    };
    executeCommand = {
      dynamicRegistration = false;
    };
    workspaceFolders = true;
    configuration = true;
  };
  textDocument = {
    synchronization = {
      dynamicRegistration = false;
      willSave = true;
      willSaveWaitUntil = true;
      didSave = true
    };
    rename = {
      prepareSupport = true
    };
    completion = {
      dynamicRegistration = false;
      completionItem = {
        snippetSupport = true;
        commitCharactersSupport = true;
        documentationFormat = { 'markdown' };
        deprecatedSupport = true;
        preselectSupport = true;
      };
      completionItemKind = {
        valueSet = vim.tbl_values(LSP.CompletionItemKind);
      };
      contextSupport = true
    };
    codeAction = {
      dynamicRegistration = false;
      codeActionLiteralSupport = {
        codeActionKind = {
          valueSet = { '', 'quickfix', 'refactor', 'refactor.extract', 'refactor.inline', 'refactor.rewrite', 'source', 'source.organizeImports' };
        }
      }
    };
    signatureHelp = {
      dynamicRegistration = false;
      signatureInformation = {
        contextSupport = true;
        documentationFormat = { 'markdown' };
        parameterInformation = {
          labelOffsetSupport = true
        }
      };
    };
    hover = {
      dynamicRegistration = false;
      contentFormat = { 'markdown' };
    };
    documentSymbol = {
      dynamicRegistration = false;
      symbolKind = {
        valueSet = vim.tbl_values(LSP.SymbolKind);
      };
      hierarchicalDocumentSymbolSupport = true
    };
    documentHighlight = {
      dynamicRegistration = false;
    };
    declaration = {
      dynamicRegistration = false;
      linkSupport = true;
    };
    definition = {
      dynamicRegistration = false;
      linkSupport = true;
    };
    typeDefinition = {
      dynamicRegistration = false;
      linkSupport = true;
    };
    implementation = {
      dynamicRegistration = false;
      linkSupport = true;
    };
    onTypeFormatting = {
      dynamicRegistration = false;
    }
  };
  experimental = {};
}

