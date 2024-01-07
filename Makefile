install_deps:
	luarocks install --local luacov
	luarocks install --local busted

test:
	busted --coverage
