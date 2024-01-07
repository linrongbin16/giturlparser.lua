install_dev:
	luarocks install --local luacov
	luarocks install --local busted

test:
	busted --coverage

pack:
	luarocks pack giturlparser-1.0.2-1.rockspec
