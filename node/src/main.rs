mod state;
mod vm;
mod zlang_tokenizer;
mod zlang_parser;
mod rpc;

use state::State;

use std::sync::{Arc, Mutex};

#[tokio::main]
async fn main() {
    let state = Arc::new(Mutex::new(State::new()));
    rpc::start_rpc(state.clone()).await;
}
