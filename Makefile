#!/usr/bin/make -f 

# https://www.gnu.org/software/make/manual/html_node/Special-Targets.html#Special-Targets
# https://devhints.io/makefile
# https://style-guides.readthedocs.io/en/latest/makefile.html
# GREAT IDEA https://swcarpentry.github.io/make-novice/08-self-doc/index.html, archived unter https://archive.is/5Y9s7 and https://web.archive.org/web/20210418110745/https://swcarpentry.github.io/make-novice/08-self-doc/index.html

.PHONY: all pip apt nasprep nascheck syscheck sysprep pythonprep inxiprep syscheckmin sysconf
.SUBFIXES: .md .pdf

MAKEFLAGS = --always-make --jobs --max-load=3 --output-sync
#--debug=jobs

daily: pip apt syscheckmin nascheck

nascheck: nasprep
	echo -e \\n\\t\\tNAS HDD 1
	ssh admin@ebelnas get_hd_smartinfo -d 1
	echo -e \\n\\t\\tNAS HDD 2
	ssh admin@ebelnas get_hd_smartinfo -d 2
	echo -e \\n\\t\\tNAS HDD 3
	ssh admin@ebelnas get_hd_smartinfo -d 3
	echo -e \\n\\t\\tNAS HDD 4
	ssh admin@ebelnas get_hd_smartinfo -d 4
	echo -e \\n\\t\\tNAS hdparm
	ssh admin@ebelnas hdparm -t /dev/sd[a-d]
	echo -e \\n\\t\\tNAS mdstat
	ssh admin@ebelnas cat /proc/mdstat
	ssh admin@ebelnas uptime

nasprep:
	ssh-copy-id -n admin@ebelnas

pip:
	sudo nice pip_upgrade_outdated --pip_cmd "/usr/bin/python3 -m pip"  --quiet

apt:
	sudo nice apt-get --quiet --quiet update
	sudo nice apt-get --quiet --quiet -y dist-upgrade

sysconf: sysprep
	@echo 'pool de.pool.ntp.org iburst' | sudo tee --append
	/etc/chrony/sources.d/basti.sources > /dev/null
	sudo chronyc reload sources

syscheckmin:
	@tput smso
	@inxi --color=0
	@tput rmso

syscheck:
#	inxi --recommends > inxi.recommends
#leading - ignores return value
#	-grep "Install package" inxi.recommends
	inxi --color=18 --verbosity 8
	-inxi --recommends | grep "Install package"
#inxi --color --full --memory --network-advanced --repos --recommends --processes --flags # -v 8

inxiprep:
	sudo nice apt-get install -y ipmitool lvm2 mdadm smartmontools upower \
	     freeipmi-tools bluez wmctrl libjson-xs-perl libjson-xs-perl \
	     libxml-dumper-perl inxi

sysprep:
	sudo nice apt-get install -y python3 \
		pandoc texlive-xetex texlive-latex-recommended lyx chktex lacheck \
		chrony conky-all needrestart needrestart-session apt-file openssh-client bash-completion
                

pythonprep:
	-sudo nice python3 -m pip uninstall --quiet --yes typing
	sudo nice python3 -m pip install --quiet --upgrade \
		joblib pandas numpy sympy tqdm \
		psutil scipy bokeh matplotlib \
		black autopep8 python-utils \
		pylint cython mypy flake8 isort \
		pandoc-plantuml-filter

pythonprepext:
	sudo nice python3 -m pip install --upgrade vaex dask mypy-extensions nbformat widgetsnbextension jupyterlab-widgets ipydatawidgets ipywidgets

jupyterprep:
	sudo nice python3 -m pip install --upgrade jupyterlab

#https://www.gnu.org/software/make/manual/html_node/Pattern-Examples.html#Pattern-Examples
%.pdf : %.md
#man pandoc gfm=github flavored markdown
	pandoc --pdf-engine=xelatex \
	    --variable=author:"Dr. Bastian Ebeling" --variable=papersize:a4 --variable=colorlinks --variable=thanks:pandoc \
	    --variable=documentclass:scrartcl --table-of-contents --listings \
		--from=gfm+definition_lists+pipe_tables+pandoc_title_block+yaml_metadata_block+smart \
		--output=$@ $< 

bashcompletionprep: sysprep
	echo eval "$$(pandoc --bash-completion)" > ~/.bashrc
