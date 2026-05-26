use crate::zlang_tokenizer::{Token, tokenize};

pub struct ZAst {
    pub tokens: Vec<Token>,
}

pub fn parse(input: &str) -> ZAst {
    ZAst {
        tokens: tokenize(input),
    }
}
