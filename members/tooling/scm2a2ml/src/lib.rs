// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
/// Scheme S-expression to A2ML converter library

use anyhow::{anyhow, Result};
use std::collections::HashMap;

/// Represents an A2ML value
#[derive(Debug, Clone, PartialEq, serde::Serialize)]
pub enum A2mlValue {
    /// String value
    String(String),
    /// Integer value
    Integer(i64),
    /// Float value
    Float(f64),
    /// Boolean value
    Boolean(bool),
    /// List of values
    List(Vec<A2mlValue>),
    /// Map/dictionary
    Map(HashMap<String, A2mlValue>),
    /// Null/None value
    Null,
}

/// Represents an A2ML document with sections
#[derive(Debug, Clone, PartialEq, serde::Serialize)]
pub struct A2mlDocument {
    /// SPDX license identifier
    pub spdx_license: Option<String>,
    /// Copyright notice
    pub copyright_notice: Option<String>,
    /// Comments at the top
    pub header_comments: Vec<String>,
    /// Sections in order
    pub sections: Vec<A2mlSection>,
}

/// Represents a section in A2ML
#[derive(Debug, Clone, PartialEq, serde::Serialize)]
pub struct A2mlSection {
    /// Section name
    pub name: String,
    /// Comments before the section
    pub comments: Vec<String>,
    /// Key-value pairs in this section
    pub entries: HashMap<String, A2mlValue>,
}

/// Represents a parsed Scheme S-expression
#[derive(Debug, Clone, PartialEq, serde::Serialize)]
pub enum SExpr {
    /// Atom (symbol or number)
    Atom(String),
    /// String
    String(String),
    /// Boolean
    Boolean(bool),
    /// Number
    Number(i64),
    /// List of S-expressions
    List(Vec<SExpr>),
    /// Dotted list (improper list)
    DottedList(Vec<SExpr>, Box<SExpr>),
    /// Quoted expression
    Quote(Box<SExpr>),
    /// Quasiquoted expression
    Quasiquote(Box<SExpr>),
}

impl SExpr {
    /// Parse a string into an S-expression
    pub fn parse(input: &str) -> Result<Vec<SExpr>> {
        let mut parser = SExprParser::new(input);
        let mut expressions = Vec::new();
        
        while parser.peek().is_some() {
            let expr = parser.parse_expr()?;
            expressions.push(expr);
            parser.consume_whitespace();
        }
        
        Ok(expressions)
    }
    
    /// Convert to A2ML document
    pub fn to_a2ml(&self) -> Result<A2mlDocument> {
        match self {
            SExpr::List(list) => {
                // The first element is typically the type (e.g., 'state, 'metadata, etc.)
                // But for top-level, we might have a list of definitions
                if list.is_empty() {
                    return Ok(A2mlDocument::default());
                }
                
                // Check if this is a (define ...) expression
                if let Some(SExpr::Atom(ref atom)) = list.get(0) {
                    if atom == "define" {
                        // This is a define expression
                        return self.convert_define(&list);
                    }
                }
                
                // Otherwise, treat as a section
                let section_name = match list.get(0) {
                    Some(SExpr::Atom(ref atom)) => atom.clone(),
                    _ => "metadata".to_string(),
                };
                
                let mut document = A2mlDocument::default();
                let section = SExpr::convert_list_to_section(&list[1..])?;
                
                // Use the section name from the first element
                let section = A2mlSection {
                    name: section_name,
                    comments: section.comments,
                    entries: section.entries,
                };
                
                document.sections.push(section);
                Ok(document)
            }
            _ => Ok(A2mlDocument::default()),
        }
    }
    
    fn convert_define(&self, list: &[SExpr]) -> Result<A2mlDocument> {
        if list.len() < 3 {
            return Err(anyhow!("Invalid define expression"));
        }
        
        // define <name> <value>
        let _name = match &list[1] {
            SExpr::Atom(s) => s.clone(),
            _ => return Err(anyhow!("Define name must be an atom")),
        };
        
        let value = &list[2];
        
        // Unwrap quotes/quasiquotes
        let value = match value {
            SExpr::Quote(expr) => expr.as_ref(),
            SExpr::Quasiquote(expr) => expr.as_ref(),
            other => other,
        };
        
        match value {
            SExpr::List(list) => {
                let mut document = A2mlDocument::default();
                let section = SExpr::convert_list_to_section(list)?;
                document.sections.push(section);
                Ok(document)
            }
            _ => Err(anyhow!("Define value must be a list")),
        }
    }
    
    fn convert_list_to_section(list: &[SExpr]) -> Result<A2mlSection> {
        let mut entries = HashMap::new();
        
        for expr in list {
            match expr {
                SExpr::List(pair) if pair.len() == 2 => {
                    // (key value) pairs
                    if let (SExpr::Atom(ref key), ref value) = (&pair[0], &pair[1]) {
                        entries.insert(key.clone(), Self::convert_value(value)?);
                    }
                }
                SExpr::List(pair) if pair.len() >= 2 => {
                    // Handle dotted pairs like (key . value) as regular pairs
                    if let SExpr::Atom(ref key) = &pair[0] {
                        let value = &pair[1];
                        entries.insert(key.clone(), Self::convert_value(value)?);
                    }
                }
                SExpr::DottedList(list_part, last) => {
                    // Handle dotted pairs: (key . value)
                    if list_part.len() == 1 {
                        if let SExpr::Atom(ref key) = &list_part[0] {
                            entries.insert(key.clone(), Self::convert_value(last)?);
                        }
                    }
                }
                SExpr::List(sub_list) => {
                    // Nested list - treat as subsection
                    let sub_section = Self::convert_list_to_section(sub_list)?;
                    // For now, flatten into the current section
                    for (k, v) in sub_section.entries {
                        entries.insert(k, v);
                    }
                }
                _ => {}
            }
        }
        
        Ok(A2mlSection {
            name: "metadata".to_string(),
            comments: vec![],
            entries,
        })
    }
    
    fn convert_value(expr: &SExpr) -> Result<A2mlValue> {
        match expr {
            SExpr::Atom(s) if s == "#t" => Ok(A2mlValue::Boolean(true)),
            SExpr::Atom(s) if s == "#f" => Ok(A2mlValue::Boolean(false)),
            SExpr::Atom(s) => {
                // Try to parse as number
                if let Ok(num) = s.parse::<i64>() {
                    return Ok(A2mlValue::Integer(num));
                }
                Ok(A2mlValue::String(s.clone()))
            }
            SExpr::String(s) => Ok(A2mlValue::String(s.clone())),
            SExpr::Boolean(b) => Ok(A2mlValue::Boolean(*b)),
            SExpr::Number(n) => Ok(A2mlValue::Integer(*n)),
            SExpr::List(list) => {
                let values: Result<Vec<A2mlValue>> = list.iter()
                    .map(|e| Self::convert_value(e))
                    .collect();
                Ok(A2mlValue::List(values?))
            }
            SExpr::DottedList(_, _) => {
                // Treat dotted list as a regular list for now
                let values: Result<Vec<A2mlValue>> = expr.to_list()?.iter()
                    .map(|e| Self::convert_value(e))
                    .collect();
                Ok(A2mlValue::List(values?))
            }
            _ => Ok(A2mlValue::Null),
        }
    }
    
    /// Convert dotted list to a regular list
    fn to_list(&self) -> Result<Vec<&SExpr>> {
        match self {
            SExpr::List(list) => Ok(list.iter().collect()),
            SExpr::DottedList(list, last) => {
                let mut result = list.iter().collect::<Vec<_>>();
                result.push(last);
                Ok(result)
            }
            _ => Err(anyhow!("Not a list")),
        }
    }
}

impl Default for A2mlDocument {
    fn default() -> Self {
        A2mlDocument {
            spdx_license: Some("MPL-2.0".to_string()),
            copyright_notice: None,
            header_comments: vec![],
            sections: vec![],
        }
    }
}

/// Parser for Scheme S-expressions
pub struct SExprParser<'a> {
    input: &'a str,
    pos: usize,
}

impl<'a> SExprParser<'a> {
    pub fn new(input: &'a str) -> Self {
        SExprParser { input, pos: 0 }
    }
    
    pub fn peek(&self) -> Option<char> {
        self.input.chars().nth(self.pos)
    }
    
    pub fn consume(&mut self) -> Option<char> {
        let ch = self.peek()?;
        self.pos += ch.len_utf8();
        Some(ch)
    }
    
    pub fn consume_whitespace(&mut self) {
        while let Some(ch) = self.peek() {
            if ch.is_whitespace() {
                self.consume();
            } else {
                break;
            }
        }
    }
    
    pub fn parse_expr(&mut self) -> Result<SExpr> {
        self.consume_whitespace();
        
        match self.peek() {
            Some(';') => {
                // Comment - skip to end of line
                self.consume(); // consume the ';'
                while let Some(ch) = self.peek() {
                    if ch == '\n' {
                        break;
                    }
                    self.consume();
                }
                self.parse_expr()
            }
            Some('"') => {
                // String
                self.consume(); // consume opening quote
                let mut s = String::new();
                while let Some(ch) = self.peek() {
                    if ch == '"' {
                        self.consume();
                        break;
                    }
                    // Handle escape sequences
                    if ch == '\\' {
                        self.consume();
                        if let Some(next) = self.peek() {
                            s.push(next);
                            self.consume();
                        }
                    } else {
                        s.push(ch);
                        self.consume();
                    }
                }
                Ok(SExpr::String(s))
            }
            Some('(') => {
                self.consume(); // consume opening paren
                let mut list = Vec::new();
                
                loop {
                    self.consume_whitespace();
                    
                    match self.peek() {
                        Some(')') => {
                            self.consume();
                            break;
                        }
                        Some('.') => {
                            // Check for dotted list
                            self.consume();
                            self.consume_whitespace();
                            let last = self.parse_expr()?;
                            self.consume_whitespace();
                            if let Some(')') = self.peek() {
                                self.consume();
                                return Ok(SExpr::DottedList(list, Box::new(last)));
                            } else {
                                return Err(anyhow!("Expected closing paren after dot"));
                            }
                        }
                        _ => {
                            let expr = self.parse_expr()?;
                            list.push(expr);
                        }
                    }
                }
                
                Ok(SExpr::List(list))
            }
            Some('`') => {
                // Quasiquote
                self.consume();
                let expr = self.parse_expr()?;
                Ok(SExpr::Quasiquote(Box::new(expr)))
            }
            Some('\'') => {
                // Quote
                self.consume();
                let expr = self.parse_expr()?;
                Ok(SExpr::Quote(Box::new(expr)))
            }
            Some('#') => {
                self.consume();
                match self.peek() {
                    Some('t') => {
                        self.consume();
                        Ok(SExpr::Boolean(true))
                    }
                    Some('f') => {
                        self.consume();
                        Ok(SExpr::Boolean(false))
                    }
                    Some('\\') => {
                        // Character
                        self.consume();
                        let ch = self.consume().ok_or(anyhow!("Expected character"))?;
                        Ok(SExpr::Atom(ch.to_string()))
                    }
                    Some(':') => {
                        // Racket-style keyword: #:keyword
                        self.consume();
                        let mut keyword = String::new();
                        while let Some(ch) = self.peek() {
                            if ch.is_ascii_alphanumeric() || ch == '-' || ch == '_' || ch == '?' || ch == '!' {
                                keyword.push(ch);
                                self.consume();
                            } else {
                                break;
                            }
                        }
                        Ok(SExpr::Atom(keyword))
                    }
                    _ => Err(anyhow!("Unknown # syntax: #{}px", self.peek().map(|c| c.to_string()).unwrap_or_default()))
                }
            }
            Some(ch) if ch.is_alphabetic() || ch.is_ascii_digit() || ch == '-' || ch == '_' || ch == '+' || ch == '.' => {
                // Symbol or number
                let mut s = String::new();
                while let Some(ch) = self.peek() {
                    if ch.is_ascii_alphanumeric() || ch == '-' || ch == '_' || ch == '+' || ch == '.' || ch == '/' || ch == ':' {
                        s.push(ch);
                        self.consume();
                    } else {
                        break;
                    }
                }
                
                // Try to parse as number
                if let Ok(num) = s.parse::<i64>() {
                    Ok(SExpr::Number(num))
                } else {
                    Ok(SExpr::Atom(s))
                }
            }
            Some(_) => {
                // Unexpected character
                Err(anyhow!("Unexpected character: {:?}", self.peek()))
            }
            None => Err(anyhow!("Unexpected end of input")),
        }
    }
}

/// Convert a Scheme S-expression string to A2ML format string
pub fn scm_to_a2ml(scm_input: &str) -> Result<String> {
    let exprs = SExpr::parse(scm_input)?;
    
    let mut output = String::new();
    
    // Add SPDX header
    output.push_str("# SPDX-License-Identifier: MPL-2.0\n");
    output.push_str("# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>\n");
    output.push_str("#\n");
    output.push_str("# Converted from .scm format\n\n");
    
    for expr in &exprs {
        let doc = expr.to_a2ml()?;
        output.push_str(&document_to_string(&doc));
        output.push('\n');
    }
    
    Ok(output)
}

/// Convert A2ML document to string
pub fn document_to_string(doc: &A2mlDocument) -> String {
    let mut output = String::new();
    
    // Add header comments
    if let Some(ref license) = doc.spdx_license {
        output.push_str(&format!("# SPDX-License-Identifier: {}\n", license));
    }
    if let Some(ref copyright_notice) = doc.copyright_notice {
        output.push_str(&format!("# {}\n", copyright_notice));
    }
    for comment in &doc.header_comments {
        output.push_str(&format!("# {}\n", comment));
    }
    if !doc.header_comments.is_empty() || doc.spdx_license.is_some() {
        output.push('\n');
    }
    
    // Add sections
    for section in &doc.sections {
        // Section header
        output.push_str(&format!("[{}]\n", section.name));
        
        // Comments
        for comment in &section.comments {
            output.push_str(&format!(";; {}\n", comment));
        }
        
        // Entries
        let mut keys: Vec<&String> = section.entries.keys().collect();
        keys.sort();
        
        for key in keys {
            let value = &section.entries[key];
            output.push_str(&format!("{} = {}\n", key, value_to_string(value)));
        }
        
        output.push('\n');
    }
    
    output
}

/// Convert A2ML value to string
fn value_to_string(value: &A2mlValue) -> String {
    match value {
        A2mlValue::String(s) => {
            if s.contains('\n') || s.contains('"') || s.contains('\\') {
                // Use triple-quoted string
                format!("\"\"\"{}\"\"\"", s)
            } else {
                format!("\"{}\"", s)
            }
        }
        A2mlValue::Integer(n) => n.to_string(),
        A2mlValue::Float(f) => f.to_string(),
        A2mlValue::Boolean(b) => if *b { "true" } else { "false" }.to_string(),
        A2mlValue::List(list) => {
            if list.is_empty() {
                "[]".to_string()
            } else if list.iter().all(|v| matches!(v, A2mlValue::String(_))) {
                // Simple string list
                let items: Vec<String> = list.iter()
                    .map(|v| match v {
                        A2mlValue::String(s) => format!("\"{}\"", s),
                        _ => value_to_string(v),
                    })
                    .collect();
                format!("[{}]", items.join(", "))
            } else {
                // Complex list - use multiline
                let mut result = String::from("[\n");
                for item in list {
                    result.push_str(&format!("  {},\n", value_to_string(item)));
                }
                result.push(']');
                result
            }
        }
        A2mlValue::Map(map) => {
            let mut result = String::from("{\n");
            let mut keys: Vec<&String> = map.keys().collect();
            keys.sort();
            for key in keys {
                result.push_str(&format!("  {} = {}\n", key, value_to_string(&map[key])));
            }
            result.push('}');
            result
        }
        A2mlValue::Null => "null".to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_parse_simple_atom() {
        let exprs = SExpr::parse("hello").unwrap();
        assert_eq!(exprs.len(), 1);
        assert_eq!(exprs[0], SExpr::Atom("hello".to_string()));
    }
    
    #[test]
    fn test_parse_string() {
        let exprs = SExpr::parse(r#""hello world""#).unwrap();
        assert_eq!(exprs.len(), 1);
        assert_eq!(exprs[0], SExpr::String("hello world".to_string()));
    }
    
    #[test]
    fn test_parse_number() {
        let exprs = SExpr::parse("42").unwrap();
        assert_eq!(exprs.len(), 1);
        assert_eq!(exprs[0], SExpr::Number(42));
    }
    
    #[test]
    fn test_parse_boolean() {
        let exprs = SExpr::parse("#t #f").unwrap();
        assert_eq!(exprs.len(), 2);
        assert_eq!(exprs[0], SExpr::Boolean(true));
        assert_eq!(exprs[1], SExpr::Boolean(false));
    }
    
    #[test]
    fn test_parse_list() {
        let exprs = SExpr::parse("(a b c)").unwrap();
        assert_eq!(exprs.len(), 1);
        match &exprs[0] {
            SExpr::List(list) => {
                assert_eq!(list.len(), 3);
                assert_eq!(list[0], SExpr::Atom("a".to_string()));
                assert_eq!(list[1], SExpr::Atom("b".to_string()));
                assert_eq!(list[2], SExpr::Atom("c".to_string()));
            }
            _ => panic!("Expected list"),
        }
    }
    
    #[test]
    fn test_parse_dotted_list() {
        let exprs = SExpr::parse("(a b . c)").unwrap();
        assert_eq!(exprs.len(), 1);
        match &exprs[0] {
            SExpr::DottedList(list, last) => {
                assert_eq!(list.len(), 2);
                assert_eq!(list[0], SExpr::Atom("a".to_string()));
                assert_eq!(list[1], SExpr::Atom("b".to_string()));
                assert_eq!(*last, SExpr::Atom("c".to_string()));
            }
            _ => panic!("Expected dotted list"),
        }
    }
    
    #[test]
    fn test_parse_nested_list() {
        let exprs = SExpr::parse("(a (b c) d)").unwrap();
        assert_eq!(exprs.len(), 1);
    }
}
