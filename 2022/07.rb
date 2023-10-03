class Tree
  def initialize()
    @root_dir = Dir.new('/', nil)
    @current_dir = @root_dir
    @directories = [@root_dir]
  end

  def add_file(name, size)
    @current_dir.add_file(name, size)
  end

  def add_dir(name)
    dir = Dir.new(name, @current_dir)
    @current_dir.children.append(dir)
    @directories.append(dir)
  end

  def navigate(name)
    if (name == '..')
      @current_dir = @current_dir.parent
    elsif (name== '/')
      return
    else
      @current_dir = @current_dir.children.find {|child| child.name == name }
    end

    throw Exception.new('Invalid navigation ' + name) if @current_dir.nil?
  end

  def directories
    @directories
  end

  def root
    @root_dir
  end

  class Dir
    def initialize(name, parent)
      @name = name.strip
      @parent = parent
      @children = []
    end

    def add_file(name, size)
      @children.append(File.new(name, size))
    end

    def children
      @children
    end

    def name
      @name
    end

    def parent
      @parent
    end

    def size
      @children.sum(&:size)
    end

  end

  class File
    def initialize(name, size)
      @name = name.strip
      @size = size
    end

    def name
      @name
    end

    def size
      @size
    end
  end
end

module Day07
  class << self

    def build_tree(input)
      tree = Tree.new

      input.lines do |line|
        case line
        when /^\$/
          cmd, _other = line.match(/^\$ ([a-z]+) ?(.+)?/).captures
          case cmd
          when 'cd'
            tree.navigate(_other)
          when 'ls'
            nil
          else
            throw Error("invalid command " + cmd)
          end
        when /^dir/
          dirname = line.gsub('dir ', '')
          tree.add_dir(dirname)
        else
          size, filename = line.split(' ')
          tree.add_file(filename, size.to_i)
        end
      end
      tree
    end

    def part_one(input)
      tree = build_tree(input)

      tree.directories.filter {|dir| dir.size <= 100000 }.sum(&:size)
    end

    def part_two(input)
      tree = build_tree(input)
      free_space = 70000000 - tree.root.size
      space_to_remove = 30000000 - free_space

      tree.directories.filter {|dir| dir.size >= space_to_remove }.map(&:size).min
    end
  end
end
