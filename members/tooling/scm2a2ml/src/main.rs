// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
use anyhow::{anyhow, Context, Result};
use clap::{Parser, ValueEnum};
use std::fs;
use std::path::PathBuf;

use scm2a2ml::{scm_to_a2ml, SExpr};

/// Convert Scheme S-expression files (.scm) to A2ML format
#[derive(Parser, Debug)]
#[command(name = "scm2a2ml")]
#[command(author = "Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>")]
#[command(version = "0.1.0")]
#[command(about = "Convert .scm files to .a2ml format")]
#[command(long_about = None)]
struct Args {
    /// Input file(s) or directory to convert
    #[arg(value_name = "INPUT")]
    input: Vec<PathBuf>,
    
    /// Output file (for single input file)
    #[arg(short, long, value_name = "OUTPUT")]
    output: Option<PathBuf>,
    
    /// Convert files in place (modify .scm files to .a2ml)
    #[arg(short, long)]
    in_place: bool,
    
    /// Output format
    #[arg(short, long, value_enum, default_value = "a2ml")]
    format: OutputFormat,
    
    /// Verbose output
    #[arg(short, long)]
    verbose: bool,
    
    /// Dry run (show what would be done without modifying files)
    #[arg(long)]
    dry_run: bool,
}

#[derive(Copy, Clone, PartialEq, Eq, PartialOrd, Ord, ValueEnum, Debug)]
enum OutputFormat {
    /// A2ML format
    A2ml,
    /// JSON format (for debugging)
    Json,
    /// Parse and pretty-print S-expressions
    Sexpr,
}

fn main() -> Result<()> {
    let args = Args::parse();
    
    if args.input.is_empty() {
        return Err(anyhow!("No input files specified"));
    }
    
    // Handle single file conversion
    if args.input.len() == 1 && !args.in_place {
        let input_path = &args.input[0];
        
        if input_path.is_file() {
            convert_file(input_path, args.output.as_ref(), &args)?;
            return Ok(());
        } else if input_path.is_dir() {
            convert_directory(input_path, &args)?;
            return Ok(());
        }
    }
    
    // Handle multiple files or in-place conversion
    for input_path in &args.input {
        if input_path.is_file() {
            if args.in_place {
                convert_file_in_place(input_path, &args)?;
            } else {
                // Output to stdout
                convert_to_stdout(input_path, &args)?;
            }
        } else if input_path.is_dir() {
            convert_directory(input_path, &args)?;
        }
    }
    
    Ok(())
}

fn convert_file(input_path: &PathBuf, output_path: Option<&PathBuf>, args: &Args) -> Result<()> {
    let input_str = fs::read_to_string(input_path)
        .with_context(|| format!("Failed to read input file: {:?}", input_path))?;
    
    if args.verbose {
        eprintln!("Converting: {:?}", input_path);
    }
    
    let output = match args.format {
        OutputFormat::A2ml => scm_to_a2ml(&input_str)?,
        OutputFormat::Json => serde_json::to_string_pretty(&SExpr::parse(&input_str)?)?,
        OutputFormat::Sexpr => format!("{:#?}", SExpr::parse(&input_str)?),
    };
    
    match output_path {
        Some(path) => {
            fs::write(path, &output)
                .with_context(|| format!("Failed to write output file: {:?}", path))?;
            if args.verbose {
                eprintln!("  Written to: {:?}", path);
            }
        }
        None => {
            println!("{}", output);
        }
    }
    
    Ok(())
}

fn convert_file_in_place(input_path: &PathBuf, args: &Args) -> Result<()> {
    let input_str = fs::read_to_string(input_path)
        .with_context(|| format!("Failed to read input file: {:?}", input_path))?;
    
    if args.verbose {
        eprintln!("Converting in place: {:?}", input_path);
    }
    
    if args.dry_run {
        let output = scm_to_a2ml(&input_str)?;
        eprintln!("  Would convert to:");
        eprintln!("{}", output);
        return Ok(());
    }
    
    let output = scm_to_a2ml(&input_str)?;
    
    // Change extension from .scm to .a2ml
    let output_path = input_path.with_extension("a2ml");
    
    fs::write(&output_path, &output)
        .with_context(|| format!("Failed to write output file: {:?}", output_path))?;
    
    if args.verbose {
        eprintln!("  Converted to: {:?}", output_path);
    }
    
    // Remove original .scm file
    if !args.dry_run {
        fs::remove_file(input_path)
            .with_context(|| format!("Failed to remove original file: {:?}", input_path))?;
        if args.verbose {
            eprintln!("  Removed original: {:?}", input_path);
        }
    }
    
    Ok(())
}

fn convert_to_stdout(input_path: &PathBuf, args: &Args) -> Result<()> {
    let input_str = fs::read_to_string(input_path)
        .with_context(|| format!("Failed to read input file: {:?}", input_path))?;
    
    let output = match args.format {
        OutputFormat::A2ml => scm_to_a2ml(&input_str)?,
        OutputFormat::Json => serde_json::to_string_pretty(&SExpr::parse(&input_str)?)?,
        OutputFormat::Sexpr => format!("{:#?}", SExpr::parse(&input_str)?),
    };
    
    println!("{}", output);
    
    Ok(())
}

fn convert_directory(dir_path: &PathBuf, args: &Args) -> Result<()> {
    if args.verbose {
        eprintln!("Processing directory: {:?}", dir_path);
    }
    
    // Find all .scm files in the directory
    let mut scm_files = Vec::new();
    
    if dir_path.is_dir() {
        for entry in walkdir::WalkDir::new(dir_path) {
            let entry = entry?;
            if entry.path().extension().map(|s| s.to_string_lossy()) == Some(std::borrow::Cow::Borrowed("scm")) {
                scm_files.push(entry.path().to_path_buf());
            }
        }
    }
    
    if scm_files.is_empty() {
        if args.verbose {
            eprintln!("  No .scm files found in directory");
        }
        return Ok(());
    }
    
    if args.verbose {
        eprintln!("  Found {} .scm files", scm_files.len());
    }
    
    for scm_file in &scm_files {
        if args.in_place {
            convert_file_in_place(scm_file, args)?;
        } else {
            convert_to_stdout(scm_file, args)?;
        }
    }
    
    if args.verbose {
        eprintln!("  Processed {} files", scm_files.len());
    }
    
    Ok(())
}
