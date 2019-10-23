enpty:
	info 'docker build for ecotruck_dev'

build:
	docker build --tag quangvinh1225/ecotruck_dev .

push:
	dpcker push quangvinh1225/ecotruck_dev

rm_image_none:
	docker rmi $(shell docker images -f "dangling=true" -q)
