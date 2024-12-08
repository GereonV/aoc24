import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Scanner;
import java.util.Set;
import java.util.function.IntFunction;

record Position(int x, int y) {
}

record Input(int width, int height, Map<Character, Set<Position>> antennas) {
	public boolean inside(int x, int y) {
		return 0 <= x && x < width && 0 <= y && y < height;
	}
}

Input parse() {
	final var antennas = new HashMap<Character, Set<Position>>();
	var width = -1;
	var height = 0;
	try (final var s = new Scanner(System.in)) {
		for (; s.hasNextLine(); height++) {
			final var line = s.nextLine();
			width = line.length();
			for (int i = 0; i < line.length(); i++) {
				final var ch = line.charAt(i);
				if (ch == '.')
					continue;
				if (!antennas.containsKey(ch))
					antennas.put(ch, new HashSet<>());
				antennas.get(ch).add(new Position(i, height));
			}
		}
	}
	return new Input(width, height, antennas);
}

// needed cause Java's generics suck
interface IntPosFunction extends IntFunction<Position> {
}

void main() {
	final var input = parse();
	final var antinodes1 = new HashSet<Position>();
	final var antinodes2 = new HashSet<Position>();
	for (final var pos : input.antennas.values()) {
		final var arr = pos.toArray(Position[]::new);
		for (var i = 0; i < arr.length; i++) {
			for (var j = i + 1; j < arr.length; j++) {
				final var pi = arr[i];
				final var pj = arr[j];
				final var dx = pi.x() - pj.x();
				final var dy = pi.y() - pj.y();
				for (final var f : new IntPosFunction[] {
						k -> new Position(pi.x() + k * dx, pi.y() + k * dy),
						k -> new Position(pj.x() - k * dx, pj.y() - k * dy)
				}) {
					for (var k = 0;; k++) {
						final var p = f.apply(k);
						if (!input.inside(p.x(), p.y()))
							break;
						if (k == 1)
							antinodes1.add(p);
						antinodes2.add(p);
					}
				}
			}
		}
	}
	System.out.println("Part 1: " + antinodes1.size());
	System.out.println("Part 2: " + antinodes2.size());
}
