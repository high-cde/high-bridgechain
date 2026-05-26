#!/data/data/com.termux/files/usr/bin/bash

echo "=== HIGH NODE RESET — Ricostruzione totale ==="

NODE=~/System.zdos/projects/high-bridgechain/node/src

echo "[1] Pulizia vecchi file"
rm -f $NODE/zlang_tokenizer.rs
rm -f $NODE/zlang_parser.rs
rm -f $NODE/zlang_vm.rs
rm -f $NODE/vm.rs
rm -f $NODE/state.rs

echo "[2] Ricostruzione tokenizer"
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

echo "[3] Ricostruzione parser"
cat << 'EOT' > $NODE/zlang_parser.rs
use crate::zlang_tokenizer::{Token, tokenize};

pub struct ZAst {
    pub tokens: Vec<Token>,
}

pub fn parse(input: &str) -> ZAst {
    ZAst {
        tokens: tokenize(input),
    }
}
EOT

echo "[4] Ricostruzione VM"
cat << 'EOT' > $NODE/vm.rs
use crate::zlang_parser::{parse, ZAst};

pub struct Vm;

impl Vm {
    pub fn new() -> Self {
        Vm
    }

    pub fn deploy(&self, _name: &str, _code: &str) -> Result<String, String> {
        Ok("contract deployed".to_string())
    }

    pub fn call(&self, _name: &str, _method: &str, _args: Vec<String>) -> Result<String, String> {
        Ok("call executed".to_string())
    }

    pub fn execute(&self, code: &str) -> Result<String, String> {
        let ast: ZAst = parse(code);
        Ok(format!("Executed {} tokens", ast.tokens.len()))
    }
}
EOT

echo "[5] Ricostruzione State"
cat << 'EOT' > $NODE/state.rs
use crate::vm::Vm;

pub struct State {
    pub height: u64,
    pub vm: Vm,
}

impl State {
    pub fn new() -> Self {
        Self {
            height: 0,
            vm: Vm::new(),
        }
    }

    pub fn apply_block(&mut self, height: u64) {
        self.height = height;
    }
}
EOT

echo "[6] Fix RPC"
sed -i '1s/^/use serde_json::json;\n/' $NODE/rpc.rs

echo "[7] Fix mod in main.rs"
MAIN=~/System.zdos/projects/high-bridgechain/node/src/main.rs
sed -i '/mod zlang_tokenizer/d' $MAIN
sed -i '/mod zlang_parser/d' $MAIN
sed -i '/mod vm/d' $MAIN
sed -i '/mod state/d' $MAIN

sed -i '1s/^/mod zlang_tokenizer;\nmod zlang_parser;\nmod vm;\nmod state;\n/' $MAIN

echo "[8] Fix Cargo.toml"
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

echo "[9] Pulizia e build"
cd ~/System.zdos/projects/high-bridgechain
cargo clean
cargo build --release

echo "=== HIGH NODE RESET COMPLETATO ==="
