TAGS ?= apt

all:

up:
	@vagrant up

provision:
	@vagrant provision

ssh:
	@vagrant ssh

destroy:
	@vagrant destroy -f

rebuild: destroy up

playbook:
	@ansible-playbook site.yml \
	$(if $(TAGS),--tags "$(TAGS)")
