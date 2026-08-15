# POST-audit status report
Repo: vscode-a2ml
Actions taken:
- Added TS blocker workflow
- Added NPM/Bun blocker workflow
- Managed lockfiles
- Synced repo (Dependabot, .scm, Justfile)
Remaining findings: {
  "program_path": ".",
  "language": "shell",
  "frameworks": [],
  "weak_points": [
    {
      "category": "UncheckedError",
      "location": ".machine_readable/contractiles/k9/template-hunt.k9.ncl",
      "file": ".machine_readable/contractiles/k9/template-hunt.k9.ncl",
      "severity": "Low",
      "description": "14 TODO/FIXME/HACK markers in .machine_readable/contractiles/k9/template-hunt.k9.ncl",
      "recommended_attack": [
        "cpu"
      ]
    },
    {
      "category": "SupplyChain",
      "location": "flake.nix",
      "file": "flake.nix",
      "severity": "High",
      "description": "flake.nix declares inputs without narHash, rev pinning, or sibling flake.lock — dependency revision is unpinned in flake.nix",
      "recommended_attack": []
    }
  ],
  "statistics": {
    "total_lines": 2483,
    "unsafe_blocks": 0,
    "panic_sites": 0,
    "unwrap_calls": 0,
    "allocation_sites": 1,
    "io_operations": 4,
    "threading_constructs": 2
  },
  "file_statistics": [
    {
      "file_path": "flake.nix",
      "lines": 170,
      "unsafe_blocks": 0,
      "panic_sites": 0,
      "unwrap_calls": 0,
      "allocation_sites": 0,
      "io_operations": 1,
      "threading_constructs": 0
    },
    {
      "file_path": "src/interface/ffi/src/main.zig",
      "lines": 274,
      "unsafe_blocks": 0,
      "panic_sites": 0,
      "unwrap_calls": 0,
      "allocation_sites": 1,
      "io_operations": 0,
      "threading_constructs": 0
    },
    {
      "file_path": "src/interface/ffi/test/integration_test.zig",
      "lines": 182,
      "unsafe_blocks": 0,
      "panic_sites": 0,
      "unwrap_calls": 0,
      "allocation_sites": 0,
      "io_operations": 0,
      "threading_constructs": 2
    },
    {
      "file_path": "setup.sh",
      "lines": 278,
      "unsafe_blocks": 0,
      "panic_sites": 0,
      "unwrap_calls": 0,
      "allocation_sites": 0,
      "io_operations": 3,
      "threading_constructs": 0
    }
  ],
  "recommended_attacks": [
    "cpu"
  ],
  "dependency_graph": {
    "edges": [
      {
        "from": "flake.nix",
        "to": "setup.sh",
        "relation": "shared_dir:",
        "weight": 1.0
      }
    ]
  },
  "taint_matrix": {
    "rows": [
      {
        "source_category": "UncheckedError",
        "sink_axis": "cpu",
        "severity_value": 1.0,
        "files": [
          ".machine_readable/contractiles/k9/template-hunt.k9.ncl"
        ],
        "frameworks": [],
        "relation": "UncheckedError->Cpu"
      }
    ]
  }
}
CRG Grade: D
