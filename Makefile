# Setup the pypi mirror
WD := $(shell pwd)
CACHE := cache
CRONLINE = "30 5 * * *" $(WD)/bin/pep381client $(WD)/$(CACHE)

install: venv mirror cache cron nginx
venv: bin/activate

bin/activate:
	virtualenv .

mirror: bin/pep381run
bin/pep381run:
	bin/pip install pep381client

$(CACHE):
	mkdir $(CACHE)

cron: /etc/cron.d/pypi_mirror
/etc/cron.d/pypi_mirror:
	echo $(CRONLINE) | sudo tee /etc/cron.d/pypi_mirror

nginx: /etc/nginx/sites-enabled/mypi nginx_check
/etc/nginx/sites-enabled/mypi: /etc/nginx/sites-available/mypi
	sudo ln -s /etc/nginx/sites-available/mypi /etc/nginx/sites-enabled/mypi
/etc/nginx/sites-available/mypi:
	sudo cp nginx.conf /etc/nginx/sites-available/mypi

.PHONY: nginx_check
nginx_check:
	sudo nginx -t

.PHONY: clean_nginx
clean_nginx:
	- sudo rm /etc/nginx/sites-available/mypi
	- sudo rm /etc/nginx/sites-enabled/mypi

.PHONY: update
update:
	bin/pep381run $(CACHE)

clean: clean_nginx
	rm -rf bin include lib local
	- sudo rm /etc/cron.d/pypi_mirror

clean_all: clean
	rm -rf $(CACHE)
