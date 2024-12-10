#![feature(iter_map_windows, cmp_minmax)]
use std::{
    cmp::minmax,
    io::{BufRead, stdin},
};

fn safe_report(report: impl IntoIterator<Item = usize>) -> bool {
    let differ = |a, b| {
        let [a, b] = minmax(a, b);
        b - a <= 3
    };
    let [d, lt, gt] = report
        .into_iter()
        .map_windows(|&[a, b]| [differ(a, b), a < b, a > b])
        .fold([true; 3], |[a1, a2, a3], [b1, b2, b3]| {
            [a1 && b1, a2 && b2, a3 && b3]
        });
    d && (lt || gt)
}

fn part1(reports: impl IntoIterator<Item = impl IntoIterator<Item = usize>>) -> usize {
    reports.into_iter().map(|r| safe_report(r) as usize).sum()
}

fn part2(
    reports: impl IntoIterator<Item = impl IntoIterator<Item = usize, IntoIter: Copy>>,
) -> usize {
    reports
        .into_iter()
        .map(IntoIterator::into_iter)
        .map(|it| {
            ((0..=it.clone().count())
                .map(|i| it.clone().take(i).chain(it.clone().skip(i + 1)))
                .any(safe_report)) as usize
        })
        .sum()
}

mod copy_iter {
    //! slice::Iter is not Copy ()
    //! no it is lol

    use core::{marker::PhantomData, mem, slice};

    #[derive(Clone, Copy)]
    pub struct UsizeIter<'a> {
        inner: [u8; mem::size_of::<slice::Iter<usize>>()],
        _marker: PhantomData<&'a usize>,
    }

    impl<'a> UsizeIter<'a> {
        pub const fn new(it: slice::Iter<'a, usize>) -> Self {
            Self {
                inner: unsafe { mem::transmute(it) },
                _marker: PhantomData,
            }
        }
    }

    impl Iterator for UsizeIter<'_> {
        type Item = usize;

        fn next(&mut self) -> Option<Self::Item> {
            let mut it: slice::Iter<usize> = unsafe { mem::transmute(self.inner) };
            let res = it.next().copied();
            self.inner = unsafe { mem::transmute(it) };
            res
        }
    }
}

fn main() {
    let reports: Vec<Vec<usize>> = stdin()
        .lock()
        .lines()
        .map(|r| {
            r.unwrap()
                .split(" ")
                .map(&str::parse)
                .map(Result::unwrap)
                .collect()
        })
        .collect();
    println!("{}", part1(reports.iter().map(|rep| rep.iter().copied())));
    println!(
        "{}",
        part2(reports.iter().map(|v| copy_iter::UsizeIter::new(v.iter())))
    );
}
