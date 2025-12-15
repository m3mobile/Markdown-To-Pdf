#!/usr/bin/env node

/**
 * M3 SDK Markdown Preprocessor
 *
 * Features:
 * - Automatically generates Table of Contents (TOC) from markdown headers
 * - Extracts Git commit history for document version tracking
 * - Inserts TOC and version history into markdown before PDF conversion
 * - Skips version history if file is not tracked by Git
 */

const fs = require('fs');
const path = require('path');
const { simpleGit } = require('simple-git');

/**
 * Generate anchor slug from header text
 * Converts "API Reference" -> "api-reference"
 */
function generateSlug(text) {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, '') // Remove special characters
    .replace(/\s+/g, '-')      // Replace spaces with hyphens
    .replace(/-+/g, '-')       // Replace multiple hyphens with single
    .trim();
}

/**
 * Extract headers from markdown content
 * Returns array of {level, text, slug}
 */
function extractHeaders(content) {
  const headers = [];
  const lines = content.split('\n');

  for (const line of lines) {
    // Match markdown headers (# to ####)
    const match = line.match(/^(#{1,4})\s+(.+)$/);
    if (match) {
      const level = match[1].length;
      const text = match[2].trim();
      const slug = generateSlug(text);

      headers.push({ level, text, slug });
    }
  }

  return headers;
}

/**
 * Generate Table of Contents markdown
 */
function generateTOC(headers) {
  let toc = '## Table of Contents\n\n';

  for (const header of headers) {
    // Skip level 1 headers (document title)
    if (header.level === 1) continue;

    // Calculate indentation (level 2 = 0, level 3 = 2, level 4 = 4)
    const indent = '  '.repeat(header.level - 2);

    // Create clickable link
    toc += `${indent}- [${header.text}](#${header.slug})\n`;
  }

  toc += '\n---\n\n';

  return toc;
}

/**
 * Get Git commit history for a file
 * Returns array of {hash, date, author, message}
 */
async function getGitHistory(filePath, repoPath) {
  try {
    const git = simpleGit(repoPath);

    // Check if git repo exists
    const isRepo = await git.checkIsRepo();
    if (!isRepo) {
      console.log(`  ℹ️  Not a Git repository, skipping version history`);
      return null;
    }

    // Get relative path from repo root
    const repoRoot = await git.revparse(['--show-toplevel']);
    const relativePath = path.relative(repoRoot.trim(), filePath);

    // Detect main/master branch
    let mainBranch = null;
    try {
      await git.revparse(['--verify', 'main']);
      mainBranch = 'main';
      console.log(`  ℹ️  Using 'main' branch for version history`);
    } catch {
      try {
        await git.revparse(['--verify', 'master']);
        mainBranch = 'master';
        console.log(`  ℹ️  Using 'master' branch for version history`);
      } catch {
        console.log(`  ⚠️  No main/master branch found, skipping version history`);
        return null;
      }
    }

    // Get commit history for this file from main/master branch only
    const log = await git.log({
      file: relativePath,
      format: {
        hash: '%h',
        date: '%ad',
        author: '%an',
        message: '%s'
      },
      '--date': 'short',
      '--follow': null,  // Follow file renames
      [mainBranch]: null  // Only commits from main/master branch
    });

    if (!log || !log.all || log.all.length === 0) {
      console.log(`  ℹ️  No Git history found for this file in ${mainBranch} branch`);
      return null;
    }

    return log.all;

  } catch (error) {
    console.log(`  ⚠️  Error getting Git history: ${error.message}`);
    return null;
  }
}

/**
 * Generate version history markdown table
 */
function generateVersionHistory(commits) {
  if (!commits || commits.length === 0) {
    return '';
  }

  let history = '## Document Version History\n\n';
  history += '| Date | Changes |\n';
  history += '|------|----------|\n';

  // Show all commits from main/master branch
  for (let i = 0; i < commits.length; i++) {
    const commit = commits[i];

    history += `| ${commit.date} | ${commit.message} |\n`;
  }

  // No extra newline after table - prevents empty row at bottom
  history += '---\n\n';

  return history;
}

/**
 * Process markdown file: add TOC and version history
 */
async function preprocessMarkdown(inputPath, outputPath, repoPath) {
  try {
    console.log(`Processing: ${path.basename(inputPath)}`);

    // Read original markdown
    const content = fs.readFileSync(inputPath, 'utf-8');

    // Extract headers for TOC
    const headers = extractHeaders(content);

    if (headers.length === 0) {
      console.log(`  ⚠️  No headers found, skipping TOC generation`);
      fs.copyFileSync(inputPath, outputPath);
      return;
    }

    // Generate TOC
    const toc = generateTOC(headers);
    console.log(`  ✓ Generated TOC with ${headers.length} headers`);

    // Get Git history
    const commits = await getGitHistory(inputPath, repoPath);
    let versionHistory = '';

    if (commits) {
      versionHistory = generateVersionHistory(commits);
      console.log(`  ✓ Generated version history with ${commits.length} commits`);
    }

    // Find insertion point (after first header, usually the title)
    const lines = content.split('\n');
    let insertIndex = 0;

    // Find first header
    for (let i = 0; i < lines.length; i++) {
      if (lines[i].match(/^#\s+/)) {
        insertIndex = i + 1;
        break;
      }
    }

    // Skip empty lines after title
    while (insertIndex < lines.length && lines[insertIndex].trim() === '') {
      insertIndex++;
    }

    // Insert TOC and version history
    const beforeTitle = lines.slice(0, insertIndex).join('\n');
    const afterTitle = lines.slice(insertIndex).join('\n');

    const processedContent = beforeTitle + '\n\n' + toc + versionHistory + afterTitle;

    // Write processed markdown
    fs.writeFileSync(outputPath, processedContent, 'utf-8');
    console.log(`  ✓ Saved to: ${path.basename(outputPath)}`);

  } catch (error) {
    console.error(`  ✗ Error processing ${inputPath}: ${error.message}`);
    throw error;
  }
}

/**
 * Main function
 */
async function main() {
  const args = process.argv.slice(2);

  if (args.length < 2) {
    console.error('Usage: node preprocess-markdown.js <input.md> <output.md> [repoPath]');
    console.error('');
    console.error('Example:');
    console.error('  node preprocess-markdown.js input.md output.md /path/to/repo');
    process.exit(1);
  }

  const inputPath = path.resolve(args[0]);
  const outputPath = path.resolve(args[1]);
  const repoPath = args[2] ? path.resolve(args[2]) : path.dirname(inputPath);

  if (!fs.existsSync(inputPath)) {
    console.error(`Error: Input file not found: ${inputPath}`);
    process.exit(1);
  }

  await preprocessMarkdown(inputPath, outputPath, repoPath);
}

// Run if called directly
if (require.main === module) {
  main().catch(error => {
    console.error('Fatal error:', error);
    process.exit(1);
  });
}

// Export for use as module
module.exports = {
  preprocessMarkdown,
  extractHeaders,
  generateTOC,
  getGitHistory,
  generateVersionHistory
};
