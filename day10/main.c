#include <stdio.h>
#include <string.h>
#include <unistd.h>

char buffer[4000];
typedef struct {
  int p1, p2;
} SR;

static SR score_and_rate(int x, int y) {
	return (SR) { 0, 0 }; // TODO
}

int main() {
  int r = read(STDIN_FILENO, buffer, sizeof buffer);
  strchr(buffer, 17);
  int w = strchr(buffer, '\n') - buffer + 1;
  int h = r / w;
  SR s = {};
  for (int y = 0; y < h; ++y)
    for (int x = 0; x + 1 < w; ++x)
      if (buffer[y * w + x]) {
        SR sr = score_and_rate(x, y);
        s.p1 += sr.p1;
        s.p2 += sr.p2;
      }
  printf("Part 1: %d\n", s.p1);
  printf("Part 2: %d\n", s.p2);
}
