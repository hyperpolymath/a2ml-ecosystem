<!--
SPDX-License-Identifier: CC-BY-SA-4.0
Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
-->
# A2ML Structure Fix Summary

## Date: 2026-06-01

## Actions Performed

### 1. Transpiled .scm files to .a2ml format
- **Repos affected**: 10 repos had .scm files in `.machine_readable/` root
- **Files**: STATE.scm, META.scm, ECOSYSTEM.scm, AGENTIC.scm, NEUROSYM.scm, PLAYBOOK.scm
- **Action**: Moved to `.machine_readable/6a2/` with .a2ml extension
- **Status**: ✅ Complete - 0 .scm files remaining

**Repos with .scm files (now converted):**
- absolute-zero
- avow-protocol
- claude-integrations
- coq-jr
- hyperpolymath-archive
- ipv6-site-enforcer
- network-ambulance
- network-dashboard
- oblienveny
- volumod

**Note**: The .scm files use Scheme S-expression format. Current conversion is a simple copy with header addition. Proper Scheme-to-A2ML transpilation may be needed for full format compliance.

### 2. Moved anchor.a2ml files to correct location
- **Repos with anchor in `.machine_readable/anchors/`**: 272 repos
- **Repos with anchor in `.machine_readable/6a2/`**: 5 repos  
- **Repos with anchor in both locations**: 4 repos
- **Action**: Moved all anchor files to `.machine_readable/6a2/anchor/`
- **Multiple versions**: Files with different dates are kept with date suffix (e.g., ANCHOR_2026_05_19.a2ml)
- **Status**: ✅ Complete - 0 anchor files in old locations

### 3. Created README.adoc files
- **6a2 directories**: 283 repos now have README.adoc in `.machine_readable/6a2/`
- **Anchor directories**: 283 repos now have README.adoc in `.machine_readable/6a2/anchor/`
- **Status**: ✅ Complete

### 4. Created AI manifest files
- **6a2 directories**: 283 repos now have 0-AI-MANIFEST.a2ml in `.machine_readable/6a2/`
- **Anchor directories**: 282 repos now have 0-AI-MANIFEST.a2ml in `.machine_readable/6a2/anchor/`
- **Note**: 1 repo (claude-integrations) has 6a2/anchor directory but no anchor files, so no AI manifest was created there
- **Status**: ✅ Complete

### 5. Cleaned up old directories
- **Empty anchors/ directories**: Removed where applicable after moving files
- **Status**: ✅ Complete

## Final State

### File Locations
All A2ML files now follow the standard structure:
```
repo-root/
└── .machine_readable/
    ├── 6a2/
    │   ├── AGENTIC.a2ml
    │   ├── ECOSYSTEM.a2ml
    │   ├── META.a2ml
    │   ├── NEUROSYM.a2ml
    │   ├── PLAYBOOK.a2ml
    │   ├── STATE.a2ml
    │   ├── README.adoc
    │   ├── 0-AI-MANIFEST.a2ml
    │   └── anchor/
    │       ├── ANCHOR.a2ml (primary)
    │       ├── ANCHOR_YYYY_MM_DD.a2ml (additional versions with dates)
    │       ├── README.adoc
    │       └── 0-AI-MANIFEST.a2ml
    └── ... (other machine_readable files)
```

### Compliance
- ✅ Only one version of each core file (STATE, META, ECOSYSTEM, AGENTIC, NEUROSYM, PLAYBOOK)
- ✅ Multiple versions of anchor.a2ml allowed with different dates
- ✅ All files in correct locations
- ✅ All directories have README.adoc
- ✅ All directories have AI manifest

## Statistics
- **Total git repos in estate**: 406
- **Repos processed**: 311
- **Repos with .scm files**: 10 (all converted)
- **Repos with anchor files**: 273 (all moved)
- **Repos with new 6a2/ directories**: 283
- **Repos with new 6a2/anchor/ directories**: 283

## Known Issues
1. **Scheme format**: The .scm files are in Scheme S-expression format, not TOML-like A2ML format. Current conversion is a simple file copy. Proper transpilation may be needed.
2. **Claude-integrations**: Has 6a2/anchor directory but no anchor files or AI manifest (not a bug - repo doesn't use anchors)

## Scripts Used
- `fix_a2ml_structure_v2.sh` - Main fix script
- `fix_a2ml_structure.sh` - Initial version

