.PHONY: format lint docgen

docgen:
	bash ./../panvimdoc/panvimdoc.sh \
		--input-file ./README.md \
		--project-name specto.nvim \
		--doc-mapping-project-name false \
		--toc true \
		--treesitter true \
		--vim-version "Neovim >= 0.9.0"

format:
	stylua lua/ --config-path=.stylua.toml

lint:
	luacheck lua/ --globals vim
