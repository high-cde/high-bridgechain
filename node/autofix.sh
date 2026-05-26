#!/data/data/com.termux/files/usr/bin/bash

echo "=== HIGH AUTOFIX — Ricostruzione nodo ==="

NODE=~/System.zdos/projects/high-bridgechain/node/src

echo "[1] Creo tokenizer"
cat << 'EOT' > $NODE/zlang_tokenizer.rs
#[derive(Debug, Clone)]
pub struct Token {
    pub value: String,
}

pub fn tokenize(input: &str) -> Vec<Token> {
    input
        .split_whitespace()
        .map(|s| Token { value: s.to_string() })
        .collect()
}
EOT

echo "[2] Creo parser"
cat << 'EOT' > $NODE/zlang_parser.rs
use crate::zlang_tokenizer::{Token, tokenize};

pub fn parse(input: &str) -> Vec<Token> {
    tokenize(input)
}
EOT

echo "[3] Creo VM minimale"
cat << 'EOT' > $NODE/vm.rs
use crate::zlang_tokenizer::tokenize;

pub struct Vm;

impl Vm {
    pub fn new() -> Self {
        Vm
    }

    pub fn execute(&self, code: &str) -> Result<String, String> {
        let tokens = tokenize(code);
        Ok(format!("Executed {} tokens", tokens.len()))
    }
}
EOT

echo "[4] Creo State con apply_block"
cat << 'EOT' > $NODE/state.rs
pub struct State {
    pub height: u64,
}

impl State {
    pub fn new() -> Self {
        Self { height: 0 }
    }

    pub fn apply_block(&mut self, height: u64) {
        self.height = height;
    }
}
EOT

echo "[5] Fix RPC macro json"
sed -i '1s/^/use serde_json::json;\n/' $NODE/rpc.rs

echo "[6] Fix mod inclusi"
MAIN=~/System.zdos/projects/high-bridgechain/node/src/main.rs
if ! grep -q "mod zlang_tokenizer" $MAIN; then
    sed -i '1s/^/mod zlang_tokenizer;\nmod zlang_parser;\nmod vm;\nmod state;\n/' $MAIN
fi

echo "[7] Fix Cargo.toml"
cat << 'EOT' > ~/System.zdos/projects/high-bridgechain/node/Cargo.toml
[package]
name = "node"
version = "0.2.0"
edition = "2021"

[dependencies]
tokio = { workspace = true }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tiny_http = "0.12"
EOT

echo "[8] Pulizia e build"
cd ~/System.zdos/projects/high-bridgechain
cargo clean
cargo build --release

echo "=== AUTOFIX COMPLETATO ==="
