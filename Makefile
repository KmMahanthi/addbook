.PHONY: default all build clean compile release shell run tar tarInDocker upgrade showdeps deb debInDocker test docker dockerCI

#export ERLANG_ROCKSDB_OPTS=-DWITH_SYSTEM_ROCKSDB=ON -DWITH_SNAPPY=ON -DWITH_LZ4=ON

rebar='rebar3'
version=$$(scripts/version)
DOCKER_UID ?= 1001
DOCKER_GID ?= 1001
DOCKER_HUB ?= packages.netstratum.com
DOCKER_IMAGE ?= erlang_ubuntu

default: compile
all: clean compile test
build: test release
compile:
	@$(rebar) compile
compileInDocker:
	@docker run -v /home:/home -v ${PWD}:/mnt -v "/etc/group:/etc/group:ro" -v "/etc/passwd:/etc/passwd:ro" -v "/etc/shadow:/etc/shadow:ro" -w /mnt -u $$(id -u):$$(id -g) $(DOCKER_HUB)/$(DOCKER_IMAGE) make
clean:
	@$(rebar) clean
cleanall:
	@$(rebar) clean -a
	@rm -rf _build/default/rel
cleanallInDocker:
	@docker run -v /home:/home -v ${PWD}:/mnt -v "/etc/group:/etc/group:ro" -v "/etc/passwd:/etc/passwd:ro" -v "/etc/shadow:/etc/shadow:ro" -w /mnt -u $$(id -u):$$(id -g) $(DOCKER_HUB)/$(DOCKER_IMAGE) make cleanall
test:
	@$(rebar) do ct
release:
	@$(rebar) release
shell:
	@$(rebar) shell
shellInDocker:
	@docker run -it -v /home:/home -v ${PWD}:/mnt -v "/etc/group:/etc/group:ro" -v "/etc/passwd:/etc/passwd:ro" -v "/etc/shadow:/etc/shadow:ro" -w /mnt -u $$(id -u):$$(id -g) $(DOCKER_HUB)/$(DOCKER_IMAGE) make shell
upgrade:
	@$(rebar) upgrade
tar:
	@$(rebar) tar
tarInDocker:
	@docker run -v /home:/home -v ${PWD}:/mnt -v "/etc/group:/etc/group:ro" -v "/etc/passwd:/etc/passwd:ro" -v "/etc/shadow:/etc/shadow:ro" -w /mnt -u $$(id -u):$$(id -g) $(DOCKER_HUB)/$(DOCKER_IMAGE) make tar
deb: tar
	@mkdir -p _pkgs/addbook-$(version)/opt/addbook
	@cp -r scripts/DEBIAN _pkgs/addbook-$(version)/
	@tar -C _pkgs/addbook-$(version)/opt/addbook/ -xf _build/default/rel/addbook/addbook-$(version).tar.gz
	@dpkg-deb --build _pkgs/addbook-$(version)
	@rm -rf _pkgs/addbook-$(version)
debInDocker: cleanallInDocker
	@docker run -v /home:/home -v ${PWD}:/mnt -v "/etc/group:/etc/group:ro" -v "/etc/passwd:/etc/passwd:ro" -v "/etc/shadow:/etc/shadow:ro" -w /mnt -u $$(id -u):$$(id -g) $(DOCKER_HUB)/$(DOCKER_IMAGE) make deb
showdeps:
	@$(rebar) tree
docker: cleanallInDocker tarInDocker
	# @docker build --build-arg version=$(version) --build-arg uid=$(DOCKER_UID) --build-arg gid=$(DOCKER_GID) -t addbook:$(version) -t addbook:latest .
	@docker build --build-arg version=$(version) -t addbook:$(version) -t addbook:latest .
dockerCI: cleanallInDocker tarInDocker
	# @docker build --build-arg version=$(version) --build-arg uid=$(DOCKER_UID) --build-arg gid=$(DOCKER_GID) -t $(DOCKER_HUB)/addbook:$(version) -t $(DOCKER_HUB)/addbook:latest .
	@docker build --build-arg version=$(version) -t $(DOCKER_HUB)/addbook:$(version) -t $(DOCKER_HUB)/addbook:latest .
	@docker push $(DOCKER_HUB)/addbook:$(version)
	@docker push $(DOCKER_HUB)/addbook:latest
	@docker rmi --force $(DOCKER_HUB)/addbook:latest
	@docker rmi --force $(DOCKER_HUB)/addbook:$(version)
