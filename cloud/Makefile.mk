
cloud-help:
	@echo "Valid targets:"
	@echo "  release      release the current version to install.gridlabd.us"
	@echo "  aws-deploy   deploy code, docs, and www to AWS"
	@echo ""
	@echo "Options:"
	@echo "   SUFFIX=-dev deploy to *-dev.gridlabd.us instead of *.gridlabd.us"


cloud-deploy: aws-deploy gcp-deploy azure-deploy

WEBSITES = code$(SUFFIX).gridlabd.us docs$(SUFFIX).gridlabd.us www$(SUFFIX).gridlabd.us

aws-deploy: $(WEBSITES)

$(WEBSITES) :
if HAVE_AWSCLI
if SUFFIX
	@echo "deploying $@ for SUFFIX='$(SUFFIX)'..."
else
	@echo "cannot deploy $@ for SUFFIX='$(SUFFIX)'"
endif
endif
# if SUFFIX
#  	@echo "aws s3 cp cloud/websites/$@/index.html s3://$@/index.html"
#  	@echo "aws s3api put-object-acl --bucket $@ --key index.html --acl public-read"
# endif

gcp-deploy:
if HAVE_GCPCLI
	@echo "WARNING: gcp-deploy is not implemented yet"
endif

azure-deploy:
if HAVE_AZCLI
	@echo "WARNING: azure-deploy is not implemented yet"
endif

install.gridlabd.us: update-requirements
	@echo "Uploading files to $@..."
	@aws s3 ls s3://$@
	@echo "WARNING: make release not implemented yet"

install-dev.gridlabd.us: $(top_srcdir)/cloud/websites/install.gridlabd.us/requirements.txt $(top_srcdir)/cloud/websites/install.gridlabd.us/validate.tarz
	@echo "Copying files to s3://$@..."
	@for file in cloud/websites/install.gridlabd.us/*{html,sh,txt}; do ( aws s3 cp "$$file" "s3://$@" && aws s3api put-object-acl --bucket "$@" --key $$(basename $$file) --acl public-read); done
	@aws s3 cp $(top_srcdir)/cloud/websites/install.gridlabd.us/validate.tarz "s3://$@/validate-$$($(top_srcdir)/build-aux/version.sh --version).tarz" 
	@aws s3api put-object-acl --bucket "$@" --key validate-$$($(top_srcdir)/build-aux/version.sh --version).tarz --acl public-read

$(top_srcdir)/cloud/websites/install.gridlabd.us/requirements.txt: 
	@cat $$(find $(top_srcdir) -name requirements.txt -print) | sort -u > $@

$(top_srcdir)/cloud/websites/install.gridlabd.us/validate.tarz:
	@tar cfz $@ $$(find $(top_srcdir) -type d -name autotest -print -prune )