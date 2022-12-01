# 🎄 Advent of Code Solutinos

Utilizes [advent_of_code_cli](https://github.com/egiurleo/advent_of_code_cli) to quickly scaffold solutions in Ruby.

## Usage

### Scaffold

This command will set up the files for any day of Advent of Code. It takes a number between 1 and 25 as an argument.

```bash
bundle exec aoc_cli scaffold 1
```

### Download

This command will download the input for a given day.

In order for this to work, you must provide your Advent of Code session cookie to the program in an environment variable:

```bash
export AOC_COOKIE=your-cookie
```

Once the environment variable is set, you can request your personal input for any day.

```bash
bundle exec aoc_cli download 1
```

### Solve

This command will run your solution to a certain day's puzzle.

```bash
bundle exec aoc_cli solve 1
```
