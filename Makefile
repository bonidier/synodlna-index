OPT_INITD_DIR = /opt/etc/init.d
OPT_INITD_FILE = S99synodlna-reindex-inotify
OPT_INITD_CONF_DIR = /opt/etc/default
OPT_INITD_CONF_FILE = synodlna-reindex-inotify

all:

	@echo "usage: make [ipkg|inotify-tools|service]"

ipkg:

	sudo ipkg install bash coreutils gcc

inotify-tools:

	./support/inotify-tools/inotify-tools_installer.sh

service:

	@ echo "** copying init.d service: ${OPT_INITD_FILE} **"
	@ if [ ! -f ${OPT_INITD_DIR}/${OPT_INITD_FILE} ]; then \
	  sudo cp -v support/init.d/${OPT_INITD_FILE} ${OPT_INITD_DIR}; \
	else \
	  echo "file ${OPT_INITD_FILE} already copied in ${OPT_INITD_DIR}"; \
	fi

	@ echo "** copying init.d config file **"
	@ if [ ! -f ${OPT_INITD_CONF_DIR}/${OPT_INITD_CONF_FILE} ]; then \
	  sudo cp -v support/init.d/conf/${OPT_INITD_CONF_FILE} ${OPT_INITD_CONF_DIR}; \
	else \
	  echo "file ${OPT_INITD_CONF_FILE} already copied in ${OPT_INITD_CONF_DIR}"; \
	fi

	@echo -e "\n/!\ don't forget to edit ${OPT_INITD_CONF_DIR}/${OPT_INITD_CONF_FILE}\n"


