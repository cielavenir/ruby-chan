# Chan: Bidirectional enumerator (channel) or the chan object like in Golang
#
# Copyright (c) 2015, T. Yamada under Ruby License (2-clause BSDL or Artistic).
#
# Check LICENSE terms.
#
# Note: MIT License is also applicable if that (somehow) compresses LICENSE file.

if RUBY_VERSION<'1.9'
	### This "require" doesn't run on mruby ###
	require 'rubygems'
	require 'threadfiber'
	ThreadFiber.deploy
end

class Chan
	# VERSION string
	VERSION='0.0.0.3'

	# Channel handler inside block.
	class Yielder
		def initialize(parent_to_child,child_to_parent)
			@parent_to_child=parent_to_child
			@child_to_parent=child_to_parent
		end
		# Loops indefinitely while parent channel is empty.
		def sync
			while @parent_to_child.empty?
				Fiber.yield(true)
			end
		end
		# Stops writing to parent queue.
		def close
			@parent_to_child.instance_eval{
				def push(v)
					raise RuntimeError.new('Pushing to closed Chan')
				end
			}
		end
		# Receives an object from parent without modifying the queue.
		def peek
			sync
			@parent_to_child.first
		end
		# Receives an object from parent.
		# aliased to next/succ.
		def receive
			sync
			@parent_to_child.shift
		end
		alias_method :next,:receive
		alias_method :succ,:receive
		# Sends an object to parent.
		# aliased to <<.
		def send(v)
			@child_to_parent.push(v)
			Fiber.yield(false)
		end
		alias_method :<<,:send
	end

	# Constructor. you should pass a block like you do in Enumerator.
	# Actually if you use Enumerator.new{} as external iterator,
	# you can safely convert it to Chan.new{} in most cases.
	def initialize(&blk)
		@f=Fiber.new{|parent_to_child,child_to_parent,blk|
			ch=Yielder.new(parent_to_child,child_to_parent)
			blk.call(ch)
		}
		@parent_to_child=[]
		@child_to_parent=[]
		@f.resume(@parent_to_child,@child_to_parent,blk)
	end

	# Tells if the channel has next element.
	# If false, it means end of enumeration or you need to give more object.
	def next?
		while @child_to_parent.empty?
			begin
				flg=@f.resume
				if flg&&@parent_to_child.empty?
					return false
				end
			rescue FiberError
				return false
			end
		end
		true
	end
	# Receives an object from child without modifying the queue.
	def peek
		raise StopIteration.new('too many read requests') if !next?
		@child_to_parent.first
	end
	# Receives an object from child.
	# aliased to next/succ.
	def receive
		raise StopIteration.new('too many read requests') if !next?
		@child_to_parent.shift
	end
	alias_method :next,:receive
	alias_method :succ,:receive
	# Sends an object to child.
	def send(v)
		@parent_to_child.push(v)
	end
	alias_method :<<,:send

	# Builds an Enumerator using existing Enumerator.
	def gen_enum(enum)
		Enumerator.new{|y|
			begin
				loop{
					self<<enum.next
					y<<self.receive if self.next?
				} # StopIteration is catched by Kernel#loop
			rescue RuntimeError
				# attempted to push to closed Chan
			end
			y<<self.receive while self.next?
		}
	end
end
