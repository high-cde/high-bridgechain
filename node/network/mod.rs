pub struct Network {
    cfg: crate::config::NodeConfig,
}

impl Network {
    pub fn new(cfg: &crate::config::NodeConfig) -> Self {
        Self { cfg: cfg.clone() }
    }

    pub async fn broadcast_block(&mut self, data: Vec<u8>) {
        println!("📡 Broadcast blocco: {} bytes", data.len());
    }

    pub async fn broadcast_tx(&mut self, data: Vec<u8>) {
        println!("📡 Broadcast tx: {} bytes", data.len());
    }
}
