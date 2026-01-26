#!/usr/bin/env bash
set -euo pipefail

# Update GitHub Actions to pin to SHA with version comments
# Usage: .github/update-actions.sh

WORKFLOWS_DIR=".github/workflows"

if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI is not installed. Install from https://cli.github.com/"
    exit 1
fi

if ! command -v yq &> /dev/null; then
    echo "Warning: yq is not installed. Using grep fallback (less reliable)."
    USE_YQ=false
else
    USE_YQ=true
fi

echo "Updating GitHub Actions to pin SHA with version comments..."
echo

# Process all workflow files
shopt -s nullglob
for workflow in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
    [[ -f "$workflow" ]] || continue
    
    echo "Processing: $workflow"
    
    # Extract all uses: lines with actions/org@version patterns
    grep -E '^\s+uses:\s+[^/]+/[^@]+@' "$workflow" | while IFS= read -r line; do
        # Extract the action reference (e.g., "actions/checkout@v4")
        action_ref=$(echo "$line" | sed -E 's/.*uses:\s+([^#]+).*/\1/' | xargs)
        
        # Skip if already pinned to SHA (40-char hex)
        if [[ "$action_ref" =~ @[0-9a-f]{40}$ ]]; then
            echo "  ✓ Already pinned: $action_ref"
            continue
        fi
        
        # Extract repo and ref
        repo=$(echo "$action_ref" | cut -d'@' -f1)
        ref=$(echo "$action_ref" | cut -d'@' -f2)
        
        echo "  Updating: $repo@$ref"
        
        # Get latest release if ref looks like a version tag
        if [[ "$ref" =~ ^v?[0-9] ]]; then
            # Fetch latest release for this major version
            major_version=$(echo "$ref" | grep -oE '^v?[0-9]+' | sed 's/v//')
            
            # Try to get the exact tag first, fallback to latest release
            release_info=$(gh api "repos/$repo/releases/tags/$ref" 2>/dev/null || \
                           gh api "repos/$repo/releases/latest" 2>/dev/null || \
                           echo "{}")
            
            tag_name=$(echo "$release_info" | jq -r '.tag_name // empty')
            release_url=$(echo "$release_info" | jq -r '.html_url // empty')
            
            if [[ -z "$tag_name" ]]; then
                echo "    ⚠ Could not fetch release info for $repo@$ref"
                continue
            fi
            
            # Get commit SHA for this tag
            tag_info=$(gh api "repos/$repo/git/refs/tags/$tag_name" 2>/dev/null || echo "{}")
            sha=$(echo "$tag_info" | jq -r '.object.sha // empty')
            
            # If tag points to a tag object, resolve to commit
            if [[ -n "$sha" ]]; then
                object_type=$(echo "$tag_info" | jq -r '.object.type // empty')
                if [[ "$object_type" == "tag" ]]; then
                    commit_info=$(gh api "repos/$repo/git/tags/$sha" 2>/dev/null || echo "{}")
                    sha=$(echo "$commit_info" | jq -r '.object.sha // empty')
                fi
            fi
            
            if [[ -z "$sha" || ${#sha} -ne 40 ]]; then
                echo "    ⚠ Could not resolve SHA for $repo@$tag_name"
                continue
            fi
            
            # Prepare the new line with SHA pinning and comment
            comment="# $tag_name, $release_url"
            new_action_ref="$repo@$sha"
            
            # Update the workflow file
            old_line=$(echo "$line" | sed 's/[\/&]/\\&/g')
            indent=$(echo "$line" | sed 's/^\(\s*\).*/\1/')
            new_line="${indent}uses: $new_action_ref $comment"
            
            # Escape for sed
            new_line_escaped=$(echo "$new_line" | sed 's/[\/&]/\\&/g')
            
            # Perform replacement
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s/$old_line/$new_line_escaped/" "$workflow"
            else
                sed -i "s/$old_line/$new_line_escaped/" "$workflow"
            fi
            
            echo "    ✓ Pinned to $sha ($tag_name)"
        else
            echo "    ⚠ Skipping non-version ref: $ref"
        fi
    done
    
    echo
done

echo "Done! Review changes with: git diff .github/workflows/"
