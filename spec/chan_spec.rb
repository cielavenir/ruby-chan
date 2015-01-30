require File.expand_path(File.dirname(__FILE__)+'/spec_helper')

describe "Chan" do
	specify "skip elements" do
		ch=Chan.new{|ch|
			loop{
				raise if ch.peek!=ch.receive
				raise if ch.peek!=ch.receive
				ch<<ch.receive*2
			}
		}
		ch.next?.should be false
		ch<<1
		ch.next?.should be false
		ch<<2
		ch.next?.should be false
		ch<<3
		ch.next?.should be true
		ch.peek.should eq 6
		ch.next.should eq 6
	end
	specify "gen_enum (chan) with loop" do
		Chan.new{|ch|
			loop{
				ch.receive
				ch.receive
				ch<<ch.receive*2
			}
		}.gen_enum(Chan.new{|y|
			a=0
			b=1
			y<<a
			20.times{
				y<<b
				a,b=b,a+b
			}
		}).take(10).should eq [2, 10, 42, 178, 754, 3194, 13530]
	end
	specify "gen_enum (enumerator) without loop" do
		Chan.new{|ch|
			#loop{
				ch.next
				ch.succ
				ch.send ch.receive*2
			#}
			ch.close
		}.gen_enum(Enumerator.new{|y|
			a=0
			b=1
			y<<a
			loop{
				y<<b
				a,b=b,a+b
			}
		}).take(10).should eq [2]
	end
end
