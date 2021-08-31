.PHONY: release
release:
	mkdir -p dist
	tar czf dist/assets.tar.gz bin lib
	cd dist && shasum -a 512 ./assets.tar.gz > sha512-checksums.txt
