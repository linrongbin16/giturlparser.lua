install_dev:
	luarocks install --local luacov
	luarocks install --local busted

test:
	busted --coverage
