
RM = rm -rf
CHMOD = chmod
MKDIR = mkdir -p
VENDOR = vendor
PHPCS = vendor/bin/phpcs
PHPCS_STANDARD = vendor/thefox/phpcsrs/Standards/TheFox
PHPCS_OPTIONS = -v -s --colors --report=full --report-width=160 --standard=$(PHPCS_STANDARD)
PHPUNIT = vendor/bin/phpunit
COMPOSER = ./composer.phar
COMPOSER_OPTIONS ?= --no-interaction

# Local installed PHPStan while supporting PHP 5.
# PHPStan requires PHP 7.
PHPSTAN = ~/.composer/vendor/bin/phpstan


.PHONY: all
all: install test

.PHONY: install
install: $(VENDOR)

.PHONY: update
update: $(COMPOSER)
	$(COMPOSER) selfupdate
	$(COMPOSER) update

.PHONY: test
test: test_phpunit

.PHONY: test_phpstan
test_phpstan:
	$(PHPSTAN) analyse --level 5 --no-progress --configuration phpstan.neon --autoload-file vendor/autoload.php src tests

.PHONY: test_phpunit
test_phpunit: $(PHPUNIT) phpunit.xml test_data
	$(PHPUNIT) $(PHPUNIT_OPTIONS)

.PHONY: test_phpunit_cc
test_phpunit_cc: build
	$(MAKE) test_phpunit PHPUNIT_OPTIONS="--coverage-html build/report"

.PHONY: test_clean
test_clean:
	$(RM) test_data

.PHONY: clean
clean:
	$(RM) composer.lock $(COMPOSER) $(VENDOR)

$(VENDOR): $(COMPOSER)
	$(COMPOSER) install $(COMPOSER_OPTIONS)

$(COMPOSER):
	curl -sS https://getcomposer.org/installer | php
	$(CHMOD) u=rwx,go=rx $(COMPOSER)

$(PHPCS): $(VENDOR)

$(PHPUNIT): $(VENDOR)

test_data:
	$(MKDIR) test_data

build:
	$(MKDIR) $@
	$(CHMOD) u=rwx,go-rwx $@
