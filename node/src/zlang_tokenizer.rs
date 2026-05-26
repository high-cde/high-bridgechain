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
