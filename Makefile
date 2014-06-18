OPT_INITD_DIR = /opt/etc/init.d
OPT_INITD_FILE = S99synodlna-reindex-inotify
OPT_INITD_CONF_DIR = /opt/etc/default
OPT_INITD_CONF_FILE = synodlna-reindex-inotify
OPT_INITD_PID_DIR = /opt/var/run

all:

	@echo "usage: make [ipkg|inotify-tools|service]"

ipkg:

	sudo ipkg install bash coreutils gcc

inotify-tools:

	./support/inotify-tools/inotify-tools_installer.sh

service:

	@ echo -e "\n** copying init.d service: ${OPT_INITD_FILE} **"
	sudo cp -v support/init.d/${OPT_INITD_FILE} ${OPT_INITD_DIR}; \

	@ echo -e "\n** copying init.d config file **"
# create config directory for init.d script if necessary
	@ if [ ! -d ${OPT_INITD_CONF_DIR} ]; then \
	  sudo mkdir -v ${OPT_INITD_CONF_DIR}; \
	fi

	@ if [ ! -f ${OPT_INITD_CONF_DIR}/${OPT_INITD_CONF_FILE} ]; then \
	  sudo cp -v support/init.d/conf/${OPT_INITD_CONF_FILE} ${OPT_INITD_CONF_DIR}; \
	else \
	  echo "${OPT_INITD_CONF_FILE} file is already present in ${OPT_INITD_CONF_DIR}"; \
	fi

	@ echo -e "\n** create ipkg's PID directory if needed **"
	@ if [ ! -d ${OPT_INITD_PID_DIR} ]; then \
	  sudo mkdir -v ${OPT_INITD_PID_DIR}; \
	else \
	  echo "directory ${OPT_INITD_PID_DIR} already present"; \
	fi

	@echo -e "\n/!\ don't forget to edit ${OPT_INITD_CONF_DIR}/${OPT_INITD_CONF_FILE}\n"


