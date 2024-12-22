#include <algorithm>
#include <array>
#include <cstddef>
#include <functional>
#include <iostream>
#include <numeric>
#include <ranges>
#include <span>
#include <vector>

namespace {
class prng {
public:
  explicit constexpr prng(std::size_t seed) noexcept : _cur{seed} {}

  constexpr std::size_t cur() const noexcept { return _cur; }

  constexpr void next() noexcept {
    _cur = mix(_cur, _cur * 64); // _cur ^= _cur << 6
    _cur = prune(_cur);
    _cur = mix(_cur, _cur / 32); // _cur ^= _cur >> 5
    _cur = prune(_cur);
    _cur = mix(_cur, _cur * 2048); // _cur ^= _cur << 11
    _cur = prune(_cur);
  }

private:
  static constexpr std::size_t mix(std::size_t a, std::size_t b) noexcept {
    return a ^ b;
  }

  static constexpr std::size_t prune(std::size_t x) noexcept {
    return x % 16777216; // x & (1 << 24) - 1
  }

  std::size_t _cur;
};

constexpr std::size_t part1(std::ranges::range auto &&monkeys) noexcept {
  return std::transform_reduce(monkeys.begin(), monkeys.end(), 0uz,
                               std::plus<>{}, [](auto m) {
                                 for (auto i = 0; i < 2000; ++i)
                                   m.next();
                                 return m.cur();
                               });
}

using sequence = std::array<int, 4>;

// not most efficient way to do this, but the easiest
constexpr std::size_t seq_idx(sequence seq) noexcept {
  return std::accumulate(seq.begin(), seq.end(), 0uz,
                         [](auto acc, auto x) { return acc * 19 + x + 9; });
}

constexpr std::size_t part2(std::ranges::range auto &&monkeys) noexcept {
  struct data {
    std::size_t sum : 63;
    bool
        local : 1; // indicates whether already seen during current prn-sequence
  };
  std::array<data, seq_idx({9, 9, 9, 9}) + 1> arr{};
  std::ranges::for_each(monkeys, [&](auto m) {
    std::ranges::for_each(arr, [](auto &d) { d.local = 0; });
    sequence seq{};
    for (auto i = 0; i < 2000; ++i) {
      std::copy(seq.begin() + 1, seq.end(), seq.begin());
      auto last = m.cur() % 10;
      m.next();
      seq[seq.size() - 1] = m.cur() % 10 - last;
      if (i < 3)
        continue;
      auto idx = seq_idx(seq);
      if (arr[idx].local)
        continue;
      arr[idx].local = true;
      arr[idx].sum += m.cur() % 10;
    }
  });
  return std::ranges::max(arr |
                          std::views::transform([](auto d) { return d.sum; }));
}

#ifndef RUNTIME
constexpr unsigned monkey_arr[] = {
	1, 2, 3 // {{input}}
};
constexpr std::span monkey_span{monkey_arr};
constexpr auto monkeys =
    monkey_span | std::views::transform([](auto m) { return prng{m}; });
constinit auto p1 = part1(monkeys);
constinit auto p2 = part2(monkeys);
#endif
} // namespace

int main() {
#ifdef RUNTIME
  std::vector<prng> monkeys;
  for (std::size_t in; std::cin >> in;)
    monkeys.emplace_back(in);
  auto p1 = part1(monkeys);
  auto p2 = part2(monkeys);
#endif
  std::cout << "Part 1: " << p1 << '\n';
  std::cout << "Part 2: " << p2 << '\n';
}
