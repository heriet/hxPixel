
test:
	docker run \
		--rm \
		--name hxpixel-test \
		-v ${PWD}:/work \
		-w /work \
		haxe:3.4.7-alpine \
		sh -c "haxe tests/compile.hxml && neko testbin/test.n"
