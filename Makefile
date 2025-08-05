# Makefile for a simple static site generator using cmark, sed, and ImageMagick.

# Use bash for advanced features like process substitution.
SHELL = /bin/bash

# --- Variables ---

# Define source, build, and template files for better organization.
SRC_DIR = content
BUILD_DIR = public
POSTS_DIR = $(SRC_DIR)/posts

# Template files
BASE_TEMPLATE = base.html
CONTENT_TEMPLATE = content.html
LIST_TEMPLATE = list.html

# CMARK is the command we'll use to convert the markdown files.
CMARK = cmark --smart

# --- File Discovery ---

# Find all Markdown files for content pages (excluding posts).
MD_FILES = $(shell find $(SRC_DIR) -maxdepth 1 -name "*.md")

# Find all Markdown files for posts.
POST_MD_FILES = $(shell find $(POSTS_DIR) -name "*.md")

# Use -iname for case-insensitive matching of image extensions.
IMAGE_SOURCES = $(shell find $(SRC_DIR) -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \))

# --- Target File Lists ---

# Define the homepage target
INDEX_PAGE = $(BUILD_DIR)/index.html

# Create a list of HTML files for regular pages, excluding the homepage.
HTML_FILES = $(filter-out $(INDEX_PAGE), $(patsubst $(SRC_DIR)/%.md,$(BUILD_DIR)/%.html,$(MD_FILES)))

# Create a list of HTML files for posts.
POST_HTML_FILES = $(patsubst $(SRC_DIR)/%.md,$(BUILD_DIR)/%.html,$(POST_MD_FILES))

# Create a robust list of target .webp files.
IMAGE_BASENAMES = $(foreach img,$(IMAGE_SOURCES),$(basename $(img)))
WEBP_FILES = $(patsubst $(SRC_DIR)/%,$(BUILD_DIR)/%.webp,$(IMAGE_BASENAMES))

# Define the main post list page target.
POST_LIST_PAGE = $(BUILD_DIR)/posts.html
RECENT_POSTS_FILE = .recent_posts.html

# --- Rules ---

# The 'all' rule is the default goal. It now depends on all generated files.
all: $(INDEX_PAGE) $(HTML_FILES) $(POST_HTML_FILES) $(WEBP_FILES) $(POST_LIST_PAGE)

# --- Page Generation Rules ---

# Rule to generate a temporary file with the 5 most recent posts.
$(RECENT_POSTS_FILE):
	@echo "Generating recent posts list..."
	@( \
		( \
			for meta_file in $(wildcard $(POSTS_DIR)/*/*.meta); do \
				. $$meta_file; \
				printf '%s\t%s\n' "$$DATE" "$$meta_file"; \
			done \
		) | sort -r | head -n 5 | cut -f 2 | while read -r meta_file; do \
			. $$meta_file; \
			post_path=$$(dirname $$meta_file | sed 's|$(SRC_DIR)/||'); \
			clean_title=$$(echo "$$TITLE" | tr -dc '[:print:]'); \
			printf '<li><a href="/%s/">%s</a></li>\n' "$$post_path" "$$clean_title"; \
		done \
	) > $@

# Rule to generate the main posts.html page using a clean pipeline.
$(POST_LIST_PAGE): $(wildcard $(POSTS_DIR)/*/*.meta) $(BASE_TEMPLATE) $(LIST_TEMPLATE)
	@mkdir -p $(BUILD_DIR)
	@echo "Generating full post list page..."
	@( \
		for meta_file in $(wildcard $(POSTS_DIR)/*/*.meta); do \
			. $$meta_file; \
			post_path=$$(dirname $$meta_file | sed 's|$(SRC_DIR)/||'); \
			clean_title=$$(echo "$$TITLE" | tr -dc '[:print:]'); \
			printf '<li><a href="/%s/">%s</a></li>\n' "$$post_path" "$$clean_title"; \
		done \
	) | sed -e "/{{post_list}}/r /dev/stdin" -e "/{{post_list}}/d" $(LIST_TEMPLATE) | \
	sed -e "s/{{title}}/All Posts/g" \
		-e "/{{content}}/r /dev/stdin" -e "/{{content}}/d" \
		$(BASE_TEMPLATE) > $@

# Rule to generate the homepage (index.html) directly into the base template.
$(INDEX_PAGE): $(SRC_DIR)/index.md $(BASE_TEMPLATE) $(RECENT_POSTS_FILE) $(wildcard $(SRC_DIR)/index.meta)
	@mkdir -p $(dir $@)
	@META_FILE=$(SRC_DIR)/index.meta; \
	if [ -f "$$META_FILE" ]; then . "$$META_FILE"; else TITLE="Homepage"; fi; \
	clean_title=$$(echo "$$TITLE" | tr -dc '[:print:]'); \
	$(CMARK) $(SRC_DIR)/index.md | \
	sed -e "/{{recent_posts}}/r $(RECENT_POSTS_FILE)" -e "/{{recent_posts}}/d" | \
	sed -e "s@{{title}}@$$clean_title@g" \
		-e "/{{content}}/r /dev/stdin" -e "/{{content}}/d" \
		$(BASE_TEMPLATE) > $@

# Rule to generate any other single post or page using[48;74;315;1258;2520t a clean pipeline.
$(HTML_FILES) $(POST_HTML_FILES): $(BUILD_DIR)/%.html: $(SRC_DIR)/%.md
	@mkdir -p $(dir $@)
	@META_FILE=$(patsubst $(BUILD_DIR)/%.html,$(SRC_DIR)/%.meta,$@); \
	if [ -f "$$META_FILE" ]; then . "$$META_FILE"; else TITLE=""; DATE=""; fi; \
	clean_title=$$(echo "$$TITLE" | tr -dc '[:print:]'); \
	if [ -n "$$DATE" ]; then \
		formatted_date=$$(date -u -jf "%Y-%m-%d %H:%M:%S" "$$DATE" +"%B %d, %Y at %H:%M %Z"); \
		date_html_content="<p><small><em>Last updated: $$formatted_date</em></small></p>"; \
	else \
		date_html_content=""; \
	fi; \
	$(CMARK) $(patsubst $(BUILD_DIR)/%.html,$(SRC_DIR)/%.md,$@) | \
	sed -e "/{{recent_posts}}/r $(RECENT_POSTS_FILE)" -e "/{{recent_posts}}/d" | \
	sed -e "s@{{title}}@$$clean_title@g" \
		-e "s@{{date}}@$$date_html_content@g" \
		-e "/{{content}}/r /dev/stdin" -e "/{{content}}/d" \
		$(CONTENT_TEMPLATE) | \
	sed -e "s@{{title}}@$$clean_title@g" \
		-e "/{{content}}/r /dev/stdin" -e "/{{content}}/d" \
		$(BASE_TEMPLATE) > $@

# --- Image Processing Rule ---

$(WEBP_FILES): $(BUILD_DIR)/%.webp:
	@# Find the source file for the current target by searching for any matching basename in the source dir.
	$(eval SOURCE_FILE := $(firstword $(wildcard $(patsubst $(BUILD_DIR)/%.webp,$(SRC_DIR)/%,$@).*)))
	@mkdir -p $(dir $@)
	@echo "Converting $(SOURCE_FILE) to $@"
	@magick "$(SOURCE_FILE)" -resize '1024x>' -colorspace Gray "$@"

# --- Utility Rules ---

# The 'serve' rule starts a simple web server in the build directory.
serve: all
	@echo "Starting server at http://localhost:8000"
	@echo "Press Ctrl+C to stop the server"
	@cd $(BUILD_DIR) && python3 -m http.server

# The 'clean' rule is used to remove the entire build directory and temporary files.
clean:
	rm -rf $(BUILD_DIR) $(RECENT_POSTS_FILE)

# Phony targets are not actual files.
.PHONY: all clean serve

