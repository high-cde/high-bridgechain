#!/data/data/com.termux/files/usr/bin/bash

echo "=== HIGH NODE FULL RESET ==="

SRC=~/System.zdos/projects/high-bridgechain/node/src

echo "[1] Rimuovo vecchi file"
rm -f $SRC/*.rs

echo "[2] Ricostruisco main.rs"
cat << 'EOT' > $SRC/main.rs
mod state;
mod vm;
mod zlang_tokenizer;
mod zlang_parser;
mod rpc;

use state::State;
use vm::Vm;

use std::sync::{Arc, Mutex};

#[tokio::main]
async fn main() {
    let state = Arc::new(Mutex::new(State::new()));
    rpc::start_rpc(state.clone()).await;
}
EOT

echo "[3] Ricostruisco state.rs"
cat << 'EOT' > $SRC/state.rs
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

echo "[4] Ricostruisco vm.rs"
cat << 'EOT' > $SRC/vm.rs
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

echo "[5] Ricostruisco tokenizer"
cat << 'EOT' > $SRC/zlang_tokenizer.rs
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

echo "[6] Ricostruisco parser"
cat << 'EOT' > $SRC/zlang_parser.rs
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

echo "[7] Ricostruisco rpc.rs"
cat << 'EOT' > $SRC/rpc.rs
use serde_json::json;
use tiny_http::{Server, Response};
use std::sync::{Arc, Mutex};
use crate::state::State;

pub async fn start_rpc(state: Arc<Mutex<State>>) {
    let server = Server::http("0.0.0.0:8765").unwrap();

    for request in server.incoming_requests() {
        let path = request.url().to_string();

        let response = match path.as_str() {
            "/height" => {
                let st = state.lock().unwrap();
                json!({ "height": st.height }).to_string()
            }
            "/execute" => {
                let st = state.lock().unwrap();
                let result = st.vm.execute("test code");
                json!({ "result": result.unwrap() }).to_string()
            }
            _ => json!({ "error": "unknown endpoint" }).to_string(),
        };

        let _ = request.respond(Response::from_string(response));
    }
}
EOT

echo "[8] Ricostruisco Cargo.toml"
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

echo "=== HIGH NODE FULL RESET COMPLETATO ==="
