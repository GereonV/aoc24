#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
constexpr int MAX_PAGE = 100;

typedef struct int_list {
  int *data;
  int size;
} int_list_t;

static int_list_t *updates;
static int updates_size;
static bool blocked[MAX_PAGE][MAX_PAGE];
static bool marked[MAX_PAGE];

static void parse() {
  int x;
  for (int y; scanf("%d|%d", &x, &y) == 2;)
    blocked[y][x] = true;
  do {
    updates = realloc(updates, ++updates_size * sizeof(int_list_t));
    auto up = &updates[updates_size - 1];
    *up = (int_list_t){};
    do {
      up->data = realloc(up->data, ++up->size * sizeof(int));
      up->data[up->size - 1] = x;
    } while (scanf(",%d", &x) == 1);
  } while (scanf("%d", &x) == 1);
}

static bool is_update_valid(int const *data, int size) {
  for (int i = 0; i < size; ++i)
    for (int j = i + 1; j < size; ++j)
      if (blocked[data[i]][data[j]])
        return false;
  return true;
}

static int visit_(int const *data, int size, int i, int *out) {
  marked[data[i]] = true;
  int sum = 0;
  for (int j = 0; j < size; ++j)
    if (!marked[data[j]] && blocked[data[i]][data[j]])
      sum += visit_(data, size, j, out + sum);
  out[sum] = data[i];
  return sum + 1;
}

static void sort_update(int *data, int size) {
  memset(marked, 0, sizeof marked);
  int_list_t sorted = {malloc(size * sizeof(int)), 0};
  for (int i = 0; i < size; ++i)
    if (!marked[data[i]])
      sorted.size += visit_(data, size, i, sorted.data + sorted.size);
  memcpy(data, sorted.data, size * sizeof(int));
  free(sorted.data);
}

int main() {
  parse();
  int sum = 0, sum2 = 0;
  for (int i = 0; i < updates_size; ++i)
    if (is_update_valid(updates[i].data, updates[i].size)) {
      sum += updates[i].data[updates[i].size / 2];
    } else {
      sort_update(updates[i].data, updates[i].size);
      sum2 += updates[i].data[updates[i].size / 2];
    }
  for (int i = 0; i < updates_size; ++i)
    free(updates[i].data);
  free(updates);
  printf("Part 1: %d\nPart 2: %d\n", sum, sum2);
}
