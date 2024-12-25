#![feature(iter_array_chunks)]

use std::io::{stdin, BufRead};
use iter::IterExt;

mod iter {
    pub struct SkipEvery<I: Iterator, const N: usize> {
        inner: I,
        idx: usize,
    }

    impl<I: Iterator, const N: usize> Iterator for SkipEvery<I, N> {
        type Item = I::Item;

        fn next(&mut self) -> Option<Self::Item> {
            if self.idx == N - 1 {
                let Some(_) = self.inner.next() else {
                    return None;
                };
                self.idx = 0;
            }
            self.idx += 1;
            self.inner.next()
        }
    }

    pub trait IterExt: Iterator {
        fn skip_every<const N: usize>(self) -> SkipEvery<Self, N> where Self: Sized {
            assert!(N > 1, "skipping everything is stupid");
            SkipEvery {
                inner: self,
                idx: 0,
            }
        }
    }

    impl<I: Iterator> IterExt for I {}
}

type Blob = [u8; 5];
type Key = Blob;
type Hole = Blob;

fn parse_input<S: AsRef<str>>(i: impl IntoIterator<Item = [S; 7]>) -> (Vec<Key>, Vec<Hole>) {
    let mut keys = Vec::new();
    let mut holes = Vec::new();
    for blob in i {
        let mut data: Blob = [0; 5];
        for row in &blob[1..6] {
            for (c, d) in row.as_ref().chars().zip(&mut data) {
                if c == '#' {
                    *d += 1;
                }
            }
        }
        match blob[0].as_ref().starts_with('#') {
            true => keys.push(data),
            false => holes.push(data),
        }
    }
    (keys, holes)
}

fn main() {
    let lines = stdin().lock().lines().map(Result::unwrap);
    let blobs = lines.skip_every::<8>().array_chunks::<7>();
    let (keys, holes) = parse_input(blobs);
    let mut c = 0;
    for k in &keys {
        for h in &holes {
            if k.iter().zip(h).all(|(k, h)| k + h <= 5) {
                c += 1;
            }
        }
    }
    println!("Possible combinations: {c}");
}
