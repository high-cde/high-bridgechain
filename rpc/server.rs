use tokio::net::TcpListener;
use tokio::io::{AsyncReadExt, AsyncWriteExt};

pub struct RpcServer;

impl RpcServer {
    pub async fn start(addr: &str) {
        let listener = TcpListener::bind(addr).await.unwrap();
        println!("🔌 RPC server su {}", addr);

        loop {
            let (mut socket, _) = listener.accept().await.unwrap();
            tokio::spawn(async move {
                let mut buf = vec![0; 1024];
                let n = socket.read(&buf).await.unwrap();
                let req = String::from_utf8_lossy(&buf[..n]);

                let resp = format!("{{\"result\":\"ok\",\"echo\":\"{}\"}}", req);
                socket.write_all(resp.as_bytes()).await.unwrap();
            });
        }
    }
}
