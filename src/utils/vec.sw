library;

use std::vec::*;

impl<T> Vec<T>
where
    T: Eq,
{
    pub fn index_of(self, value: T) -> Option<u64> {
        let mut i = 0;
        while (i < self.len()) {
            if value == self.get(i).unwrap() {
                return Some(i);
            }
            i += 1;
        }

        None
    }

    fn sort(ref mut self)
    where
        T: Ord,
    {
        let mut n = self.len();
        while (n > 1) {
            let mut i = 0;
            while (i < n - 1) {
                if self.get(i).unwrap() > self.get(i + 1).unwrap() {
                    self.swap(i, i + 1);
                }
                i += 1;
            }
            n -= 1;
        }
    }
}

impl<T> Vec<T> {
    pub fn with(self, value: T) -> Self {
        let mut vec = self;
        vec.push(value);

        vec
    }
}

impl<T> Eq for Vec<T>
where
    T: Eq,
{
    fn eq(self, other: Self) -> bool {
        if (self.len() != other.len()) {
            return false;
        }

        let mut i = 0;
        while (i < self.len()) {
            if self.get(i).unwrap() != other.get(i).unwrap() {
                return false;
            }

            i += 1;
        }

        true
    }
}

impl u256 {
    fn avg_with(self, other: Self) -> Self {
        self.rsh(1) + other.rsh(1) + (self % 2 + other % 2) / 2
    }
}

impl Vec<u256> {
    pub fn median(self) -> u256 {
        match self.len() {
            0 => revert(0),
            1 => self.get(0).unwrap(),
            2 => self.get(0).unwrap().avg_with(self.get(1).unwrap()),
            _ => {
                let mut values = self;

                values.sort();

                let mid = values.len() / 2;
                if (values.len() % 2 == 1) {
                    values.get(mid).unwrap()
                } else {
                    values.get(mid).unwrap().avg_with(values.get(mid - 1).unwrap())
                }
            }
        }
    }

    pub fn log(self) {
        let mut i = 0;
        while (i < self.len()) {
            log(self.get(i).unwrap());
            i += 1;
        }
    }
}

#[test]
fn test_avg_with() {
    assert(0x444u256.avg_with(0x222u256) == 0x333u256);
    assert(0x444u256.avg_with(0x444u256) == 0x444u256);
    assert(0x444u256.avg_with(0x0u256) == 0x222u256);
    assert(0x333u256.avg_with(0x222u256) == 0x2aau256);
    assert(0x333u256.avg_with(0x333u256) == 0x333u256);
    assert(0x0u256.avg_with(0x0u256) == 0x0u256);
    assert(u256::max().avg_with(u256::max()) == u256::max());
}

#[test]
fn test_median_single_value() {
    let data = Vec::new().with(0x333u256);

    assert(data.median() == 0x333u256);
}

#[test]
fn test_median_two_values() {
    let data = Vec::new().with(0x333u256).with(0x222u256);

    assert(data.median() == 0x2aau256);
}

#[test]
fn test_median_three_values() {
    let data = Vec::new().with(0x444u256).with(0x222u256).with(0x333u256);

    assert(data.median() == 0x333u256);
}

#[test]
fn test_median_four_values() {
    let data = Vec::new().with(0x444u256).with(0x222u256).with(0x111u256).with(0x555u256);

    assert(data.median() == 0x333u256);
}

#[test]
fn test_median_five_values() {
    let data = Vec::new().with(0x444u256).with(0x222u256).with(0x111u256).with(0x333u256).with(0x555u256);

    assert(data.median() == 0x333u256);
}

#[test]
fn test_median_three_other_values() {
    let data = Vec::new().with(0x222u256).with(0x222u256).with(0x333u256);

    assert(data.median() == 0x222u256);
}

#[test(should_revert)]
fn test_median_zero_values() {
    let _ = Vec::<u256>::new().median();
}
