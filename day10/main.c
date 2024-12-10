#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

char buffer[4000];
bool endpoint[sizeof buffer];
typedef struct {
  int p1, p2;
} SR;
static int const offsets[][2] = {
    {1, 0},
    {-1, 0},
    {0, 1},
    {0, -1},
};

static SR score_and_rate(int x, int y, int w, int h) {
  int p = y * w + x;
  if (buffer[p] == '9') {
    int p1 = !endpoint[p];
    endpoint[p] = true;
    return (SR){p1, 1};
  }
  SR res = {};
  for (int const(*tupptr)[2] = offsets;
       tupptr != offsets + sizeof offsets / sizeof *offsets; ++tupptr) {
    int nx = x + (*tupptr)[0];
    int ny = y + (*tupptr)[1];
    int np = ny * w + nx;
    if (nx < 0 || nx >= w - 1 || ny < 0 || ny >= h ||
        buffer[np] != buffer[p] + 1)
      continue;
    SR rec = score_and_rate(nx, ny, w, h);
    res.p1 += rec.p1;
    res.p2 += rec.p2;
  }
  return res;
}

int main() {
  int r = read(STDIN_FILENO, buffer, sizeof buffer);
  strchr(buffer, 17);
  int w = strchr(buffer, '\n') - buffer + 1;
  int h = r / w;
  SR s = {};
  for (int y = 0; y < h; ++y)
    for (int x = 0; x + 1 < w; ++x)
      if (buffer[y * w + x] == '0') {
        memset(endpoint, 0, sizeof endpoint);
        SR sr = score_and_rate(x, y, w, h);
        s.p1 += sr.p1;
        s.p2 += sr.p2;
      }
  printf("Part 1: %d\n", s.p1);
  printf("Part 2: %d\n", s.p2);
}
