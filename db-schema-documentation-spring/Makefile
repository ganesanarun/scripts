export-schema: validate-dependencies
	./export-schema.sh $(PROFILE)

convert-to-dbml: validate-dependencies
	@sql2dbml docs/sql/ddl.sql > docs/sql/schema.dbml
	@echo "DBML file created at docs/sql/schema.dbml"

render-svg: validate-dependencies create-directories
	@dbml-renderer -i docs/sql/schema.dbml -o docs/sql/images/schema.svg
	@echo "SVG file created at docs/svg/schema.svg"

document-schema: validate-dependencies
	@$(MAKE) export-schema PROFILE=$(PROFILE)
	@$(MAKE) convert-to-dbml
	@$(MAKE) render-svg

validate-dependencies:
	@command -v pg_dump > /dev/null || (echo "pg_dump is not installed. Please install it using 'brew install postgresql'"; exit 1)
	@command -v sql2dbml > /dev/null || (echo "sql2dbml is not installed. Please install it using 'npm install -g sql2dbml'"; exit 1)
	@command -v dbml-renderer > /dev/null || (echo "dbml-renderer is not installed. Please install it using 'npm install -g dbml-renderer'"; exit 1)
	@command -v yq > /dev/null || (echo "yq is not installed. Please install it using 'brew install yq'"; exit 1)
	@command -v awk > /dev/null || (echo "awk is not installed. Please install it using 'brew install gawk'"; exit 1)

create-directories:
	@mkdir -p docs/sql/images