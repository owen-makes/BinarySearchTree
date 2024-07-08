class Node
  include Comparable
  attr_accessor :data, :right, :left

  def initialize(data, left = nil, right = nil)
    @data = data
    @right = right
    @left = left
  end

  def <=>(other)
    @data <=> other
  end

  def count_children
    count = 0
    count += @right.nil? ? 0 : 1
    count += @left.nil? ? 0 : 1
    count
  end

  def find_successor
    current = self
    parent = nil

    while current
      parent = current
      current = current.left
    end
    parent
  end
end

class Tree
  attr_accessor :root

  def initialize(arr)
    @root = build_tree(arr)
  end

  def pretty_print(node = @root, prefix = '', is_left = true)
    pretty_print(node.right, "#{prefix}#{is_left ? '│   ' : '    '}", false) if node.right
    puts "#{prefix}#{is_left ? '└── ' : '┌── '}#{node.data}"
    pretty_print(node.left, "#{prefix}#{is_left ? '    ' : '│   '}", true) if node.left
  end

  def insert(value)
    if @root.nil?
      @root = Node.new(value)
      return
    end

    current = @root
    parent = nil

    while current
      case current <=> (value)
      in -1
        parent = current
        current = current.right
      in 1
        parent = current
        current = current.left
      else
        return
      end
    end

    if value < parent.data
      parent.left = Node.new(value)
    else
      parent.right = Node.new(value)
    end
  end

  def delete(value)
    current = @root
    parent = nil

    begin
      until current.data == value
        case current <=> (value)
        in -1
          parent = current
          current = current.right
        in 1
          parent = current
          current = current.left
        end
      end
    rescue StandardError
      return nil
    end

    case current.count_children
    in 0
      current.data > parent.data ? parent.right = nil : parent.left = nil
      nil
    in 1
      current = current.left || current.right
      current.data > parent.data ? parent.right = current : parent.left = current
    else
      successor = current.find_successor
      delete(successor.data)
      current.data = successor.data
    end 
  end

  def find(value)
    current = @root
    begin
      until current.data == value
        case current <=> (value)
        in -1
          current = current.right
        in 1
          current = current.left
        end
      end
    rescue StandardError
      return nil
    end

    current
  end

  def level_order(node = @root)
    return if node.nil?

    queue = []
    values = []

    queue.push(node)

    until queue.empty?
      node = queue.shift
      yield node if block_given?
      values << node.data
      node.left.nil? ?  nil : queue.push(node.left)
      node.right.nil? ? nil : queue.push(node.right)
    end
    values
  end

  def inorder(node = @root)
    return [] if node.nil?

    result = []
    result += inorder(node.left)
    # Left - Root - Right
    if block_given?
      yield node
    else
      result << node.data
    end

    result += inorder(node.right)

    result
  end

  def preorder(node = @root)
    return [] if node.nil?

    # Root - Left - Right
    result = []
    if block_given?
      yield node
    else
      result << node.data
    end

    result += inorder(node.left)
    result += inorder(node.right)

    result
  end

  def postorder(node = @root)
    return [] if node.nil?

    # Left - Right - Root
    result = []
    result += inorder(node.left)
    result += inorder(node.right)

    if block_given?
      yield node
    else
      result << node.data
    end

    result
  end

  def height(node = @root)
    return 0 if node.nil?

    if node.count_children.zero?
      1
    else
      [height(node.left), height(node.right)].max + 1
    end
  end

  def depth(node = @root)
    depth = 0
    current = @root
    value = node.data

    until current.data == value
      case current <=> (value)
      when -1
        current = current.right
        depth += 1
      when 1
        current = current.left
        depth += 1
      end
    end

    depth
  end

  def balanced?(node = @root)
    condition = (height(node.left) - height(node.right)).abs

    condition <= 1
  end

  def rebalance
    a = inorder
    initialize(a)
  end

  private

  def build_tree(arr)
    return nil if arr.empty?

    arr = arr.uniq.sort
    mid = arr.size / 2
    Node.new(arr[mid], build_tree(arr[0...mid]), build_tree(arr[mid + 1..]))
  end
end

test = Tree.new((Array.new(15) { rand(1..100) }))

p test.balanced?
p test.preorder
p test.postorder
p test.inorder
test.insert(101)
test.insert(102)
test.insert(103)
test.insert(104)
test.insert(105)
p test.balanced?
test.rebalance
p test.balanced?
p test.preorder
p test.postorder
p test.inorder
