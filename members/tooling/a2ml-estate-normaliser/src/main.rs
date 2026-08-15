// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
use anyhow::{Context, Result};
use clap::{Parser, ValueEnum};
use regex::Regex;
use std::collections::HashSet;
use std::ffi::OsStr;
use std::fs;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;

/// Estate-wide A2ML (Attestation Markup Language) file normaliser
/// 
/// Ensures all A2ML files follow the correct structure:
/// - Core files (STATE, META, ECOSYSTEM, AGENTIC, NEUROSYM, PLAYBOOK) in .machine_readable/6a2/
/// - Anchor files in .machine_readable/6a2/anchor/
/// - Only one version of each core file (multiple anchor versions allowed with dates)
/// - README.adoc and AI manifest in each directory
#[derive(Parser, Debug)]
#[command(name = "a2ml-estate-normaliser")]
#[command(author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>")]
#[command(version = "0.1.0")]
#[command(about = "Normalize A2ML files across the entire estate")]
struct Args {
    /// Estate root directory (default: auto-detect from script location)
    #[arg(long, value_name = "DIRECTORY")]
    estate_root: Option<PathBuf>,

    /// Actually perform changes (default is dry-run)
    #[arg(short, long)]
    execute: bool,

    /// Verbose output
    #[arg(short, long)]
    verbose: bool,

    /// Only process specific repos (comma-separated)
    #[arg(short, long, value_name = "REPOS")]
    repos: Option<String>,

    /// Mode of operation
    #[arg(short, long, value_enum, default_value = "full")]
    mode: Mode,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum, Debug)]
enum Mode {
    /// Full normalization: check and fix everything
    Full,
    /// Only check, report issues
    Check,
    /// Only fix .scm transpilation
    Transpile,
    /// Only fix file locations
    Organize,
    /// Only create missing README and manifest files
    Documents,
}

// Core A2ML file names
const CORE_SCM_FILES: &[&str] = &[
    "STATE.scm",
    "META.scm",
    "ECOSYSTEM.scm",
    "AGENTIC.scm",
    "NEUROSYM.scm",
    "PLAYBOOK.scm",
];

const CORE_A2ML_FILES: &[&str] = &[
    "STATE.a2ml",
    "META.a2ml",
    "ECOSYSTEM.a2ml",
    "AGENTIC.a2ml",
    "NEUROSYM.a2ml",
    "PLAYBOOK.a2ml",
];

const ANCHOR_FILES: &[&str] = &["ANCHOR.a2ml", "anchor.a2ml"];

// Templates for generated files
const README_6A2: &str = r#"# A2ML 6a2 Directory

This directory contains the 6 core A2ML machine-readable metadata files for this repository.

## Files

- `AGENTIC.a2ml` - AI agent operational gating, safety controls
- `ECOSYSTEM.a2ml` - Project ecosystem position, relationships, explicit boundaries
- `META.a2ml` - Architecture decisions (ADRs), development practices, design rationale
- `NEUROSYM.a2ml` - Symbolic semantics, composition algebra
- `PLAYBOOK.a2ml` - Executable plans, operational runbooks
- `STATE.a2ml` - Project state, phase, milestones, session history

## Standards Compliance

These files follow the A2ML Format Family specification from:
https://github.com/hyperpolymath/standards/tree/main/a2ml

## Generation

These files may be generated from .scm source files using transpilation tools.
Source .scm files should be removed after successful transpilation.

## See Also

- [A2ML Repository Template](https://github.com/hyperpolymath/standards/blob/main/A2ML-REPO-TEMPLATE.adoc)
- [6A2 Format Family](https://github.com/hyperpolymath/standards#a2ml-format-family-7-formats)
"#;

const README_ANCHOR: &str = r#"# A2ML Anchor Directory

This directory contains ANCHOR.a2ml files for project recalibration and scope intervention.

## Files

- `ANCHOR.a2ml` - Project recalibration, scope intervention, canonical authority

## Multiple Versions

Unlike other A2ML files, multiple versions of ANCHOR.a2ml with different dates may exist.
Each version represents a specific recalibration point in the project history.

## Standards Compliance

These files follow the ANCHOR.a2ml specification from:
https://github.com/hyperpolymath/standards/tree/main/anchor-a2ml

## See Also

- [A2ML Repository Template](https://github.com/hyperpolymath/standards/blob/main/A2ML-REPO-TEMPLATE.adoc)
- [Anchor A2ML Spec](https://github.com/hyperpolymath/standards/tree/main/anchor-a2ml)
"#;

const AI_MANIFEST_6A2: &str = r#"# AI Manifest for 6a2 Directory

## Purpose

This manifest declares the AI-assistant context for the 6a2 machine-readable metadata directory.

## Canonical Locations

The 6 core A2ML files MUST exist in this directory:
1. AGENTIC.a2ml
2. ECOSYSTEM.a2ml
3. META.a2ml
4. NEUROSYM.a2ml
5. PLAYBOOK.a2ml
6. STATE.a2ml

## Invariants

- No duplicate files in root directory
- Single source of truth: this directory is authoritative
- No stale metadata

## Protocol

When multiple agents may write to A2ML files concurrently:
1. Read file and record git-sha-at-read in [provenance] section
2. Lock by creating .lock-<FILENAME>
3. Write updated file with new [provenance] metadata
4. Release by removing lock file
5. On conflict: re-read and retry if git-sha-at-read does not match HEAD
"#;

const AI_MANIFEST_ANCHOR: &str = r#"# AI Manifest for Anchor Directory

## Purpose

This manifest declares the AI-assistant context for the anchor machine-readable metadata directory.

## Canonical Locations

ANCHOR.a2ml files MUST exist in this directory.

## Multiple Versions

Unlike other A2ML files, multiple versions of ANCHOR.a2ml with different dates MAY exist.
Each version represents a specific recalibration point.

## Invariants

- Multiple versions with different dates are permitted
- No other A2ML files in this directory
- Single source of truth for anchor documents
"#;

fn main() -> Result<()> {
    let args = Args::parse();

    let estate_root = args.estate_root.clone().unwrap_or_else(|| {
        // Auto-detect estate root
        let mut path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
        // Go up from a2ml/a2ml-estate-normaliser to repos
        while path.file_name() != Some(std::ffi::OsStr::new("repos")) {
            if !path.pop() {
                break;
            }
        }
        path
    });

    if args.verbose {
        eprintln!("Estate root: {:?}", estate_root);
        eprintln!("Mode: {:?}", args.mode);
        eprintln!("Execute: {}", args.execute);
    }

    // Get all git repos
    let repos = find_git_repos(&estate_root)?;
    
    if args.verbose {
        eprintln!("Found {} git repos", repos.len());
    }

    // Filter repos if specified
    let repos_to_process = if let Some(ref repo_filter) = args.repos {
        let filter_set: HashSet<_> = repo_filter.split(',').collect();
        repos.into_iter()
            .filter(|r| filter_set.contains(r.file_name().unwrap().to_str().unwrap()))
            .collect()
    } else {
        repos
    };

    if args.verbose {
        eprintln!("Processing {} repos", repos_to_process.len());
    }

    // Process each repo
    let mut total_issues = 0;
    let mut total_fixes = 0;

    for repo_path in &repos_to_process {
        let repo_name = repo_path.file_name().unwrap().to_string_lossy();
        
        if args.verbose {
            eprintln!("\n=== Processing: {} ===", repo_name);
        }

        match process_repo(repo_path, &args) {
            Ok(repo_fixes) => {
                total_fixes += repo_fixes;
            }
            Err(e) => {
                eprintln!("ERROR processing {}: {}", repo_name, e);
                total_issues += 1;
            }
        }
    }

    eprintln!("\n=== Summary ===");
    eprintln!("Repos processed: {}", repos_to_process.len());
    eprintln!("Issues encountered: {}", total_issues);
    
    if args.execute {
        eprintln!("Fixes applied: {}", total_fixes);
    } else {
        eprintln!("Fixes that would be applied: {}", total_fixes);
    }

    if total_issues > 0 {
        anyhow::bail!("Encountered {} issues", total_issues);
    }

    Ok(())
}

/// Find all git repository roots under the estate root
fn find_git_repos(estate_root: &Path) -> Result<Vec<PathBuf>> {
    let mut repos = Vec::new();
    
    for entry in WalkDir::new(estate_root).max_depth(3) {
        let entry = entry?;
        if entry.file_name() == ".git" && entry.path().is_dir() {
            // The parent directory is the git repo root
            if let Some(parent) = entry.path().parent() {
                repos.push(parent.to_path_buf());
            }
        }
    }
    
    // Remove duplicates and sort
    repos.sort();
    repos.dedup();
    
    Ok(repos)
}

/// Process a single repository
fn process_repo(repo_path: &Path, args: &Args) -> Result<usize> {
    let mut fixes = 0;
    let mr_dir = repo_path.join(".machine_readable");
    
    // Check if .machine_readable exists
    if !mr_dir.exists() {
        if args.verbose {
            eprintln!("  No .machine_readable directory, skipping");
        }
        return Ok(0);
    }

    let mr_6a2_dir = mr_dir.join("6a2");
    let mr_6a2_anchor_dir = mr_6a2_dir.join("anchor");
    let mr_anchors_dir = mr_dir.join("anchors");

    // Ensure 6a2 directories exist
    if args.execute {
        fs::create_dir_all(&mr_6a2_dir)?;
        fs::create_dir_all(&mr_6a2_anchor_dir)?;
    }

    // Step 1: Handle .scm files -> transpile to .a2ml in 6a2/
    if args.mode == Mode::Full || args.mode == Mode::Transpile {
        fixes += handle_scm_files(&mr_dir, &mr_6a2_dir, args)?;
    }

    // Step 2: Handle core .a2ml files in wrong locations
    if args.mode == Mode::Full || args.mode == Mode::Organize {
        fixes += handle_core_a2ml_files(repo_path, &mr_dir, &mr_6a2_dir, args)?;
    }

    // Step 3: Handle anchor files
    if args.mode == Mode::Full || args.mode == Mode::Organize {
        fixes += handle_anchor_files(&mr_dir, &mr_6a2_dir, &mr_6a2_anchor_dir, &mr_anchors_dir, args)?;
    }

    // Step 4: Ensure README.adoc and AI manifest exist
    if args.mode == Mode::Full || args.mode == Mode::Documents {
        fixes += ensure_readme_and_manifest(&mr_6a2_dir, &mr_6a2_anchor_dir, args)?;
    }

    // Step 5: Clean up old directories
    if args.mode == Mode::Full || args.mode == Mode::Organize {
        fixes += cleanup_old_directories(&mr_dir, &mr_anchors_dir, args)?;
    }

    Ok(fixes)
}

/// Handle .scm files - transpile to .a2ml and move to 6a2/
fn handle_scm_files(mr_dir: &Path, mr_6a2_dir: &Path, args: &Args) -> Result<usize> {
    let mut fixes = 0;
    
    // Find all .scm files in .machine_readable directory (excluding 6a2/)
    for entry in WalkDir::new(mr_dir).max_depth(5) {
        let entry = entry?;
        let path = entry.path();
        
        // Skip if already in 6a2 directory
        if path.components().any(|c| c.as_os_str() == "6a2") {
            continue;
        }
        
        let filename = path.file_name().unwrap().to_string_lossy();
        
        // Check if it's a core .scm file
        if CORE_SCM_FILES.iter().any(|&f| filename == *f) {
            let a2ml_name = filename.replace(".scm", ".a2ml");
            let a2ml_path = mr_6a2_dir.join(&a2ml_name);

            // Check if .a2ml already exists in 6a2/
            if a2ml_path.exists() {
                if args.execute {
                    // Remove the .scm file (duplicate)
                    fs::remove_file(path)
                        .with_context(|| format!("Failed to remove duplicate .scm file: {:?}", path))?;
                    eprintln!("  Removed duplicate .scm: {}", filename);
                } else {
                    eprintln!("  Would remove duplicate .scm: {}", filename);
                }
                fixes += 1;
            } else {
                // Transpile and move
                if args.execute {
                    let a2ml_content = transpile_scm_to_a2ml(&fs::read_to_string(path)?, &a2ml_name)?;
                    fs::write(&a2ml_path, &a2ml_content)?;
                    fs::remove_file(path)?;
                    eprintln!("  Transpiled: {} -> 6a2/{}", filename, a2ml_name);
                } else {
                    eprintln!("  Would transpile: {} -> 6a2/{}", filename, a2ml_name);
                }
                fixes += 1;
            }
        }
    }

    Ok(fixes)
}

/// Transpile .scm content to .a2ml format
fn transpile_scm_to_a2ml(scm_content: &str, filename: &str) -> Result<String> {
    let timestamp = chrono::Utc::now().format("%Y-%m-%dT%H:%M:%SZ").to_string();
    let year = chrono::Utc::now().format("%Y").to_string();

    let mut output = String::new();
    
    // Add A2ML header
    output.push_str("# SPDX-License-Identifier: MPL-2.0\n");
    output.push_str(&format!("# Copyright (c) {} Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>\n", year));
    output.push_str("#\n");
    output.push_str(&format!("# {} — Transpiled from .scm format\n", filename));
    output.push_str("[metadata]\n");
    output.push_str(&format!("converted-from-scm = true\n"));
    output.push_str(&format!("conversion-date = \"{}\"\n", timestamp));
    output.push_str("\n");
    
    // Add the original content
    output.push_str(scm_content);

    Ok(output)
}

/// Handle core .a2ml files that are in wrong locations
fn handle_core_a2ml_files(_repo_path: &Path, mr_dir: &Path, mr_6a2_dir: &Path, args: &Args) -> Result<usize> {
    let mut fixes = 0;
    
    // Find all core .a2ml files in wrong locations
    // Wrong locations: anywhere in .machine_readable except 6a2/ and 6a2/anchor/
    for a2ml_file in CORE_A2ML_FILES {
        
        for entry in WalkDir::new(mr_dir).max_depth(5) {
            let entry = entry?;
            if entry.file_name() == OsStr::new(a2ml_file) {
                let entry_path = entry.path();
                
                // Skip if already in correct location
                if entry_path.parent() == Some(mr_6a2_dir) || 
                   entry_path.parent().and_then(|p| p.parent()) == Some(mr_6a2_dir) {
                    continue;
                }

                let dest_path = mr_6a2_dir.join(a2ml_file);

                // Check if already exists in 6a2/
                if dest_path.exists() {
                    if args.execute {
                        // Remove the file from wrong location
                        fs::remove_file(entry_path)
                            .with_context(|| format!("Failed to remove duplicate: {:?}", entry_path))?;
                        eprintln!("  Removed duplicate: {} from {:?}", a2ml_file, entry_path.parent());
                    } else {
                        eprintln!("  Would remove duplicate: {} from {:?}", a2ml_file, entry_path.parent());
                    }
                    fixes += 1;
                } else {
                    if args.execute {
                        // Move to correct location
                        fs::rename(entry_path, &dest_path)
                            .or_else(|_| {
                                // If rename fails (cross-device), copy and delete
                                fs::copy(entry_path, &dest_path)?;
                                fs::remove_file(entry_path)
                            })
                            .with_context(|| format!("Failed to move {} to 6a2/", a2ml_file))?;
                        eprintln!("  Moved: {} to 6a2/", a2ml_file);
                    } else {
                        eprintln!("  Would move: {} from {:?} to 6a2/", a2ml_file, entry_path.parent());
                    }
                    fixes += 1;
                }
            }
        }
    }

    Ok(fixes)
}

/// Handle anchor files
fn handle_anchor_files(mr_dir: &Path, mr_6a2_dir: &Path, mr_6a2_anchor_dir: &Path, mr_anchors_dir: &Path, args: &Args) -> Result<usize> {
    let mut fixes = 0;
    
    // Collect all anchor files
    let mut anchor_files = Vec::new();
    
    // Look in .machine_readable/anchors/
    if mr_anchors_dir.exists() {
        for entry in fs::read_dir(mr_anchors_dir)? {
            let entry = entry?;
            if ANCHOR_FILES.iter().any(|&f| entry.file_name() == OsStr::new(f)) {
                anchor_files.push(entry.path());
            }
        }
    }
    
    // Look in .machine_readable/6a2/ (but not in 6a2/anchor/)
    if mr_6a2_dir.exists() {
        for entry in fs::read_dir(mr_6a2_dir)? {
            let entry = entry?;
            let path = entry.path();
            if ANCHOR_FILES.iter().any(|&f| entry.file_name() == OsStr::new(f)) && 
               path.parent() != Some(mr_6a2_anchor_dir) {
                anchor_files.push(path);
            }
        }
    }
    
    // Look in .machine_readable/ root
    for anchor_file in ANCHOR_FILES {
        let path = mr_dir.join(anchor_file);
        if path.exists() {
            anchor_files.push(path);
        }
    }

    // Process each anchor file
    for anchor_path in &anchor_files {
        let filename = anchor_path.file_name().unwrap().to_string_lossy().to_string();
        let is_dated = Regex::new(r"ANCHOR_\d{4}_\d{2}_\d{2}\.a2ml").unwrap().is_match(&filename);
        
        // Determine destination
        let dest_path = if is_dated {
            mr_6a2_anchor_dir.join(&filename)
        } else {
            mr_6a2_anchor_dir.join("ANCHOR.a2ml")
        };

        // Check if destination exists
        if dest_path.exists() {
            if args.execute {
                // Check if files are different
                let src_content = fs::read_to_string(anchor_path)?;
                let dest_content = fs::read_to_string(&dest_path)?;
                
                if src_content != dest_content {
                    // Add date suffix to the source file
                    let metadata = fs::metadata(anchor_path)?;
                    let modified = metadata.modified()?;
                    let sys_time: chrono::DateTime<chrono::Utc> = modified.into();
                    let date_suffix = sys_time.format("%Y_%m_%d").to_string();
                    let new_filename = format!("ANCHOR_{}.a2ml", date_suffix);
                    let new_dest = mr_6a2_anchor_dir.join(&new_filename);
                    
                    fs::rename(anchor_path, &new_dest)
                        .or_else(|_| {
                            fs::copy(anchor_path, &new_dest)?;
                            fs::remove_file(anchor_path)
                        })?;
                    eprintln!("  Moved anchor with date suffix: {} -> {}", filename, new_filename);
                } else {
                    // Remove duplicate
                    fs::remove_file(anchor_path)?;
                    eprintln!("  Removed duplicate anchor: {}", filename);
                }
            } else {
                eprintln!("  Would handle anchor: {}", filename);
            }
            fixes += 1;
        } else {
            if args.execute {
                let new_dest = if filename == "anchor.a2ml" {
                    mr_6a2_anchor_dir.join("ANCHOR.a2ml")
                } else {
                    mr_6a2_anchor_dir.join(&filename)
                };
                
                fs::rename(anchor_path, &new_dest)
                    .or_else(|_| {
                        fs::copy(anchor_path, &new_dest)?;
                        fs::remove_file(anchor_path)
                    })?;
                eprintln!("  Moved anchor: {} to 6a2/anchor/", filename);
            } else {
                eprintln!("  Would move anchor: {} to 6a2/anchor/", filename);
            }
            fixes += 1;
        }
    }

    Ok(fixes)
}

/// Ensure README.adoc and AI manifest exist in directories
fn ensure_readme_and_manifest(mr_6a2_dir: &Path, mr_6a2_anchor_dir: &Path, args: &Args) -> Result<usize> {
    let mut fixes = 0;
    
    // Check 6a2 directory
    let readme_6a2_path = mr_6a2_dir.join("README.adoc");
    if !readme_6a2_path.exists() {
        if args.execute {
            fs::write(&readme_6a2_path, README_6A2)?;
            eprintln!("  Created README.adoc in 6a2/");
        } else {
            eprintln!("  Would create README.adoc in 6a2/");
        }
        fixes += 1;
    }
    
    let manifest_6a2_path = mr_6a2_dir.join("0-AI-MANIFEST.a2ml");
    if !manifest_6a2_path.exists() {
        let alt_path = mr_6a2_dir.join("AI-MANIFEST.a2ml");
        if !alt_path.exists() {
            if args.execute {
                fs::write(&manifest_6a2_path, AI_MANIFEST_6A2)?;
                eprintln!("  Created AI manifest in 6a2/");
            } else {
                eprintln!("  Would create AI manifest in 6a2/");
            }
            fixes += 1;
        }
    }
    
    // Check anchor directory
    let readme_anchor_path = mr_6a2_anchor_dir.join("README.adoc");
    if !readme_anchor_path.exists() {
        // Only create if there are anchor files
        if mr_6a2_anchor_dir.exists() && fs::read_dir(mr_6a2_anchor_dir)?.count() > 0 {
            if args.execute {
                fs::write(&readme_anchor_path, README_ANCHOR)?;
                eprintln!("  Created README.adoc in 6a2/anchor/");
            } else {
                eprintln!("  Would create README.adoc in 6a2/anchor/");
            }
            fixes += 1;
        }
    }
    
    let manifest_anchor_path = mr_6a2_anchor_dir.join("0-AI-MANIFEST.a2ml");
    if !manifest_anchor_path.exists() {
        let alt_path = mr_6a2_anchor_dir.join("AI-MANIFEST.a2ml");
        if !alt_path.exists() {
            // Only create if there are anchor files
            if mr_6a2_anchor_dir.exists() && fs::read_dir(mr_6a2_anchor_dir)?.count() > 0 {
                if args.execute {
                    fs::write(&manifest_anchor_path, AI_MANIFEST_ANCHOR)?;
                    eprintln!("  Created AI manifest in 6a2/anchor/");
                } else {
                    eprintln!("  Would create AI manifest in 6a2/anchor/");
                }
                fixes += 1;
            }
        }
    }
    
    Ok(fixes)
}

/// Clean up old directories that are now empty
fn cleanup_old_directories(_mr_dir: &Path, mr_anchors_dir: &Path, args: &Args) -> Result<usize> {
    let mut fixes = 0;
    
    // Check if anchors/ directory is empty
    if mr_anchors_dir.exists() {
        let count = fs::read_dir(mr_anchors_dir)?.count();
        if count == 0 {
            if args.execute {
                fs::remove_dir(mr_anchors_dir)?;
                eprintln!("  Removed empty anchors/ directory");
            } else {
                eprintln!("  Would remove empty anchors/ directory");
            }
            fixes += 1;
        }
    }
    
    Ok(fixes)
}
