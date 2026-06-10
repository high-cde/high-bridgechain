use serde_json::json;
use tiny_http::{Server, Response, Method};
use std::sync::{Arc, Mutex};
use crate::state::State;

pub async fn start_rpc(state: Arc<Mutex<State>>) {
    let server = Server::http("0.0.0.0:8765").unwrap();

    for mut request in server.incoming_requests() {
        let method = request.method().clone();
        let path = request.url().to_string();

        let response = match (method, path.as_str()) {

            // Healthcheck
            (Method::Get, "/ping") => {
                json!({ "status": "ok" }).to_string()
            }

            // Altezza del nodo
            (Method::Get, "/height") => {
                let st = state.lock().unwrap();
                json!({ "height": st.height }).to_string()
            }

            // Esecuzione codice Z‑Lang
            (Method::Post, "/execute") => {
                let body = request.as_reader();
                let code = std::io::read_to_string(body).unwrap_or_default();

                let st = state.lock().unwrap();
                let result = st.vm.execute(&code);

                json!({ "result": result.unwrap() }).to_string()
            }

            // Deploy contratto
            (Method::Post, "/deploy") => {
                let body = request.as_reader();
                let payload = std::io::read_to_string(body).unwrap_or_default();

                let st = state.lock().unwrap();
                let result = st.vm.deploy("contract", &payload);

                json!({ "deploy": result.unwrap() }).to_string()
            }

            // Call contratto
            (Method::Post, "/call") => {
                let body = request.as_reader();
                let payload = std::io::read_to_string(body).unwrap_or_default();

                let st = state.lock().unwrap();
                let result = st.vm.call("contract", "method", vec![payload]);

                json!({ "call": result.unwrap() }).to_string()
            }

            // Endpoint sconosciuto
            _ => json!({ "error": "unknown endpoint" }).to_string(),
        };

        let _ = request.respond(Response::from_string(response));
    }
}
