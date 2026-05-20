use protocol::block::Block;
use serde::{Serialize, Deserialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Account {
    pub id: String,
    pub balance: i64,
    pub nonce: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Validator {
    pub id: String,
    pub stake: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Genesis {
    pub accounts: Vec<Account>,
    pub validators: Vec<Validator>,
}

pub struct State {
    pub height: u64,
    pub accounts: Vec<Account>,
    pub validators: Vec<Validator>,
}

impl State {
    pub fn load_genesis(path: &str) -> Self {
        let data = std::fs::read_to_string(path).unwrap();
        let genesis: Genesis = serde_json::from_str(&data).unwrap();

        Self {
            height: 0,
            accounts: genesis.accounts,
            validators: genesis.validators,
        }
    }

    pub fn apply_block(&mut self, block: &Block) {
        self.height = block.header.height;
    }
}
